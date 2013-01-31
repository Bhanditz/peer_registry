class Site < ActiveRecord::Base
  attr_accessible :auth_code, :current_uuid, :name, :response_url, :url

  has_many :pull_events
  has_many :push_requests
  belongs_to :current_state_push_request, :class_name => 'PushRequest', :foreign_key => :current_uuid, :primary_key => :uuid

  before_create :generate_auth_code

  def self.authenticate(auth_code)
    return Site.find_by_auth_code(auth_code)
  end

  def unprocessed_pulls
    pull_events.where('success_at IS NULL')
  end

  def up_to_date?
    latest_successful_push = PushRequest.latest_successful_push
    return true if latest_successful_push.nil?
    current_uuid == PushRequest.latest_successful_push.uuid
  end

  private

  def generate_auth_code
    self.auth_code = UUIDTools::UUID.timestamp_create().to_s unless self.auth_code?
  end

end
