class PullRequestsController < ApplicationController

  before_filter :set_response_format_to_json
  before_filter :authenticate_site, :only => [ :pull, :report ]
  before_filter :validate_current_uuid, :only => [ :pull ]

  def pull
    # Check if there is any pending pull for this site
    return render_error(405, 'Another pull is in progress') if @site.unprocessed_pulls.count > 0

    latest_successful_push = PushRequest.latest_successful_push
    return render_error(208, 'Nothing to pull') if latest_successful_push.nil?  # there haven't been any pushes
    return render_error(208, 'Nothing to pull') if @site.current_uuid == latest_successful_push.uuid  # already up-to-date

    peer_logs = PeerLog.new_logs_for_site(@site) # Get Peer Logs for pending pushes
    combined_logs = PeerLog.combine_logs_in_one_json(peer_logs) # Convert the logs to json format

    pull_event = PullEvent.new  # create the pull
    pull_event.site_id = @site.id
    pull_event.pull_at = DateTime.now
    pull_event.state_uuid = latest_successful_push.uuid
    pull_event.save

    file_url = File.join(Rails.root, 'public', 'files', "#{pull_event.id}.json")
    file_md5_hash = File.join(Rails.root, 'public', 'files', "#{pull_event.id}.md5")

    pull_event.file_url = "/files/#{pull_event.id}.json"
    pull_event.file_md5_hash = "/files/#{pull_event.id}.md5"

    pull_event.save

    # prepare file for syncing
    File.open(file_url, 'w')  do |f|
      f.write(combined_logs.to_json)
    end

    # create the md5 hash
    File.open(file_md5_hash, 'w')  do |f|
      f.write(Digest::MD5.hexdigest(combined_logs.to_json))
    end

    # Now prepare the pull response in json
    resp_arr = {}
    resp_arr['file_url'] = "#{REGISTRY_URL}#{pull_event.file_url}"
    resp_arr['file_md5_hash'] = "#{REGISTRY_URL}#{pull_event.file_md5_hash}"
    resp_arr['UUID'] = latest_successful_push.uuid

    render :json => resp_arr.to_json
  end

  def report
    uuid = params[:uuid]
    success = params[:success]
    reason = params[:reason]
    return render_error(400, 'Missing parameters') if uuid.blank? || success.blank?

    # get the Pull
    pull_event = PullEvent.find_by_site_id_and_state_uuid(@site.id, uuid)
    return render_error(406, 'Invalid Pull') unless pull_event
    # the pull had already succeeded or failed
    return render_error(406, 'Pull has already been completed') if pull_event.success

    if success.to_i > 0
      pull_event.success = 1
      pull_event.success_at = DateTime.now
      pull_event.save

      @site.current_uuid = uuid
      @site.save
    else
      pull_event.success = 0
      pull_event.failed_at = DateTime.now
      pull_event.failed_reason = reason
      pull_event.save
    end

    render :json => { :success => pull_event.success, :uuid => @site.current_uuid }.to_json
  end

end
