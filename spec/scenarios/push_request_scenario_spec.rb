require 'spec_helper'

describe PushRequest do 

  before (:all) do
    truncate_all_tables
  end

  it 'should send success after successfull push' do
    push_request = PushRequest.new
    push_request.success = 1
    push_request.save

    uuid = push_request.uuid

    visit "/push_requests/query?uuid=#{uuid}"
    body.should include('"success":1')
  end

  it 'should accept push and send uuid' do
    # create a site
    site = Site.gen(:auth_code => "test_123")

    # create an empty push

    push_request = PushRequest.new
    push_request.success = 1
    push_request.save

    uuid = push_request.uuid

    # assign the new uuid to the site
    site.current_uuid = uuid
    site.save

    # send a push request and get the results
    visit "/push_requests/make_push?auth_code=#{site.auth_code}&current_uuid=#{uuid}&file_url=http://www.example.com/test.json&file_md5_hash=http://www.example.com/test.json"    
    body.should include('"message":"processing"')
  end
end