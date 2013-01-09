require 'factory_girl_rails'

FactoryGirl.define do

  sequence(:string)     { |n| "unique#{ n }string" }
  sequence(:url)        { |n| "http://example#{ n }.com/" }

  factory :log_action_parameter do
    association         :peer_log
    association         :param_object_type, :factory => :sync_object_type
    association         :param_object_site, :factory => :site
    parameter           { generate(:string) }
    value               { generate(:string) }
  end

  factory :peer_log do
    association         :user_site, :factory => :site
    association         :sync_object_action
    association         :sync_object_type
    association         :push_request
  end

  factory :pull_event do
    association         :site
    pull_at             { Time.now }
    success_at          { Time.now }
    state_uuid          { UUIDTools::UUID.timestamp_create().to_s }
  end

  factory :push_request do
    association         :site
    file_url            { site.url + generate(:string) }
    file_md5_hash       { Digest::MD5.hexdigest(generate(:string)) }
    received_at         { Time.now }
    success_at          { Time.now }
    success             true
  end

  factory :site do
    name                { generate(:string) }
    url                 { generate(:url) }
    response_url        { url + "sync_event_update" }
  end

  factory :sync_object_action do
    object_action       { generate(:string) }
  end

  factory :sync_object_type do
    object_type         { generate(:string) }
  end

end