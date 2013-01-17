class PeerLog < ActiveRecord::Base
  attr_accessible :action_taken_at_time, :push_request_id, :sync_object_action_id, :sync_object_id,
                  :sync_object_site_id, :sync_object_type_id, :user_site_id, :user_site_object_id

  belongs_to :push_request
  belongs_to :sync_object_type
  belongs_to :sync_object_action
  belongs_to :sync_object_site, :class_name => 'Site', :foreign_key => :sync_object_site_id
  belongs_to :user_site, :class_name => 'Site', :foreign_key => :user_site_id
  
  has_many :log_action_parameter
  
  
  def self.get_for_a_pull(push_request, site_id)
    PeerLog.find(:all,
                 :order => 'action_taken_at_time',
                 :joins => :push_request,
                 :conditions => ["received_at > ? and site_id <> ? and success=1", push_request.received_at, site_id])
        
  end
end
