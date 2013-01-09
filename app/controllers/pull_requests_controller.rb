class PullRequestsController < ApplicationController
  def pull
    auth_code = params[:auth_code]
    current_uuid = params[:current_uuid]
    
    unless auth_code && current_uuid
      @message = view_context.error_message_to_json('Missing Parameters')
      render :json => @message
      return
    end
    
    # authenticate site
    site = Site.authenticate(auth_code)

    unless site
      @message = view_context.error_message_to_json('Invalid auth_code')
      render :json => @message
      return
    end

    # make sure that the site and the registry have the same UUID for this site 
    # TODO: if this check fails, then this node is out of sync. we need to figure out a procedure to fix this!
    unless (site.current_uuid == current_uuid)
      @message = view_context.error_message_to_json('Invalid current_uuid')
      render :json => @message
      return
    end
    
    # Get push for this uuid
    push_request = PushRequest.find_by_uuid(current_uuid)
    
    # get the uuid the node should have after the pull is success
    uuid_to_be = PushRequest.get_uuid_to_be(push_request, current_uuid, site.id)
    
    if (uuid_to_be == current_uuid)
      # Nothing new to pull,
      # return the same uuid
      resp_arr = {}
      resp_arr['UUID'] = uuid_to_be
      render :json => resp_arr.to_json      
    else  
      
      # Get Peer Logs for pending pushes
      peer_logs = PeerLog.get_for_a_pull(push_request, site.id)
      
      # Convert the logs to json format
      logs_arr = combine_logs_in_one_json(peer_logs)
      
      # create the pull
      pull_event = PullEvent.new
      pull_event.site_id = site.id
      pull_event.pull_at = DateTime.now
      pull_event.state_uuid = uuid_to_be
      
      pull_event.save
      
      file_url = File.join(Rails.root, "public", "files", "#{pull_event.id}.json")
      file_md5_hash = File.join(Rails.root, "public", "files", "#{pull_event.id}.md5")
      
      pull_event.file_url = "/files/#{pull_event.id}.json"
      pull_event.file_md5_hash = "/files/#{pull_event.id}.md5"
      
      pull_event.save
      
      # prepare file for syncing
      File.open(file_url, 'w')  do |f| 
        f.write(logs_arr.to_json) 
      end
      
      # create the md5 hash
      File.open(file_md5_hash, 'w')  do |f| 
        f.write(Digest::MD5.hexdigest(logs_arr.to_json))
      end
      
      # Now prepare the pull response in json
      resp_arr = {}
      resp_arr['file_url'] = "#{REGISTRY_URL}#{pull_event.file_url}"
      resp_arr['file_md5_hash'] = "#{REGISTRY_URL}#{pull_event.file_md5_hash}"
      resp_arr['UUID'] = uuid_to_be
      
      render :json => resp_arr.to_json
    end
  end
end
