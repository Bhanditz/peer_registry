class PushRequest < ActiveRecord::Base
  attr_accessible :failed_at, :failed_reason, :file_md5_hash, :file_url
  attr_accessible :received_at, :site_id, :success, :success_at, :uuid

  belongs_to :site

  before_create :generate_uuid

  def self.registry_is_busy?
    self.where("success is null").count > 0
  end
  
  def self.get_uuid_to_be(push_request, uuid, site_id)    
    # get the latest uuid that the node should have when the pull is success
    pr = PushRequest.find(:first, 
                          :select => 'uuid',
                          :conditions => ["received_at > ? and site_id <> ? and success=1", push_request.received_at, site_id],
                          :order => "received_at DESC")

    if pr
      pr.uuid
    else
      push_request.uuid
    end
     
    
  end
  
  private

    def generate_uuid
      self.uuid = UUIDTools::UUID.timestamp_create().to_s unless self.uuid?
    end

end
