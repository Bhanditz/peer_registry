module PullRequestsHelper
  def combine_logs_in_one_json(peer_logs)
    logs_arr = {}
    
    peer_logs.each do |peer_log|
      pl_arr = {}
      pl_arr[:user_site_id] = peer_log.user_site_id
      pl_arr[:user_site_object_id] = peer_log.user_site_object_id
      pl_arr[:action_taken_at_time] = peer_log.action_taken_at_time
      pl_arr[:sync_object_action] = peer_log.sync_object_action.object_action
      pl_arr[:sync_object_type] = peer_log.sync_object_type.object_type
      pl_arr[:sync_object_id] = peer_log.sync_object_id
      pl_arr[:sync_object_site_id] = peer_log.sync_object_site_id
      
      laps = {}
      peer_log.log_action_parameters.each do |lap|
        lap_arr = {}
        lap_arr[:param_object_id] = lap.param_object_id
        lap_arr[:param_object_site_id] = lap.param_object_site_id
        lap_arr[:param_object_type_id] = lap.sync_object_type.object_type
        lap_arr[:parameter] = lap.parameter
        lap_arr[:value] = lap.value
        
        laps << lap_arr
      end 
      
      pl_arr[:log_action_parameters] = laps
      
      logs_arr << pl_arr      
    end
    
    logs_arr
  end
  
end
