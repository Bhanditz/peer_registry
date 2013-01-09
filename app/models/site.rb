class Site < ActiveRecord::Base
  attr_accessible :auth_code, :current_uuid, :name, :response_url, :url

  has_many :pull_events
  has_many :push_requests

  before_create :generate_auth_code

  def self.authenticate(auth_code)
    return Site.find_by_auth_code(auth_code)
  end



  private

    def generate_auth_code
      self.auth_code = UUIDTools::UUID.timestamp_create().to_s unless self.auth_code?
    end

end
