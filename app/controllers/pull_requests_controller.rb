class PullRequestsController < ApplicationController
  def pull
    auth_code = params[:auth_code]
    current_uuid = params[:current_uuid]
    
    unless auth_code && current_uuid
      render_error('Missing parameters') && return
    end
    
    # authenticate site
    site = Site.authenticate(auth_code)

    unless site
      render_error('Invalid auth_code') && return
    end

    # make sure that the site and the registry have the same UUID for this site 
    # TODO: if this check fails, then this node is out of sync. we need to figure out a procedure to fix this!
    unless (site.current_uuid == current_uuid)
      render_error('Invalid current_uuid') && return
    end
    
    # Check if there is any pending pull for this site
    if any_pending_pulls_for_site(site)
      render_error('Another pull is in progress') && return
    end
        
    # Get push for this uuid
    push_request = PushRequest.find_by_uuid(current_uuid)
    
    # get the uuid the node should have after the pull is success
    uuid_to_be = PushRequest.get_uuid_to_be(push_request, current_uuid, site.id)
    
    if (uuid_to_be == current_uuid)
      # Nothing new to pull,
      render_error('Nothing  to pull') && return
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
  
  def report
    auth_code = params[:auth_code]
    uuid = params[:uuid]
    success = params[:success]
    reason = params[:reason]
    
    unless auth_code && uuid && success
      render_error('Missing parameters') && return
    end
    
    # authenticate site
    site = Site.authenticate(auth_code)

    unless site
      render_error('Invalid auth_code') && return
    end

    # get the Pull
    pull_event = PullEvent.find_by_site_id_and_state_uuid(site.id, uuid)
    
    unless pull_event
      render_error('Invalid Pull') && return
    end
    
    if success.to_i > 0
      pull_event.success = 1
      pull_event.success_at = DateTime.now
      pull_event.save
      
      site.current_uuid = uuid
      site.save     
    else
      pull_event.success = 0
      pull_event.failed_at = DateTime.now
      pull_event.failed_reason = reason
      pull_event.save
    end
    
    
    resp_arr = {}
    resp_arr['success'] = pull_event.success
    resp_arr['uuid'] = site.current_uuid
    
    render :json => resp_arr.to_json
  end
  
  private
  
  def render_error(error_message)
    json_hash = {
      :success => 0,
      :message => error_message }
    render :json => json_hash.to_json, :status => 400
  end
  
  def combine_logs_in_one_json(peer_logs)
    logs_arr = Array.new
    
    peer_logs.each do |peer_log|
      pl_arr = {}
      pl_arr[:user_site_id] = peer_log.user_site_id
      pl_arr[:user_site_object_id] = peer_log.user_site_object_id
      pl_arr[:action_taken_at_time] = peer_log.action_taken_at_time
      pl_arr[:sync_object_action] = peer_log.sync_object_action.object_action
      pl_arr[:sync_object_type] = peer_log.sync_object_type.object_type
      pl_arr[:sync_object_id] = peer_log.sync_object_id
      pl_arr[:sync_object_site_id] = peer_log.sync_object_site_id
      
      laps = Array.new
      peer_log.log_action_parameter.each do |lap|
        lap_arr = {}
        lap_arr[:param_object_id] = lap.param_object_id if lap.param_object_id
        lap_arr[:param_object_site_id] = lap.param_object_site_id if lap.param_object_site_id
        lap_arr[:param_object_type] = lap.param_object_type.object_type if lap.param_object_type_id
        lap_arr[:parameter] = lap.parameter
        lap_arr[:value] = lap.value
        
        laps << lap_arr
      end
      
      pl_arr[:log_action_parameters] = laps
      
      logs_arr << pl_arr      
    end
    
    logs_arr
  end
  
  def any_pending_pulls_for_site(site)
    pending_count = PullEvent.where(['site_id = ? and success is null', site.id]).count
    if pending_count > 0 
      return true
    else
      return false
    end
  end

end
