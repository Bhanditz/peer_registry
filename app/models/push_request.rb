class PushRequest < ActiveRecord::Base
  attr_accessible :failed_at, :failed_reason, :file_md5_hash, :file_url
  attr_accessible :received_at, :site_id, :success, :success_at, :uuid

  belongs_to :site

  before_create :generate_uuid

  def self.pending
    self.where('success is null')
  end

  def self.latest_successful_push
    PushRequest.where('success = 1').order('id DESC').first rescue nil
  end

  private

  def generate_uuid
    self.uuid = UUIDTools::UUID.timestamp_create().to_s unless self.uuid?
  end

end
