class PullEvent < ActiveRecord::Base
  attr_accessible :pull_at, :site_id, :state_uuid, :success_at, :success, :file_url, :file_md5_hash, :failed_at, :failed_reason

  belongs_to :site
end
