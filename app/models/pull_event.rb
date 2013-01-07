class PullEvent < ActiveRecord::Base
  attr_accessible :pull_at, :site_id, :state_uuid, :success_at

  belongs_to :site
end
