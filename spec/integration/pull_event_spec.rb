require 'spec_helper'

describe PullEvent do 

  before :all do
    truncate_all_tables
    
    # create a site
    @site = Site.gen(:auth_code => "test_123")
    
    # create an empty push
    push_request = PushRequest.new
    push_request.success = 1
    push_request.save
    
    uuid = push_request.uuid

    # assign the new uuid to the site
    @site.current_uuid = uuid
    @site.save
  end
  
  it 'should reject pull and report Nothing to pull' do
    visit "/pull_requests/pull?auth_code=#{@site.auth_code}&current_uuid=#{@site.current_uuid}"
    body.should include('"message":"Nothing to pull"')    
  end
  
  it 'should accept pull and send UUID' do
    # create an empty push
    push_request = PushRequest.new
    push_request.success = 1
    push_request.save
    
    visit "/pull_requests/pull?auth_code=#{@site.auth_code}&current_uuid=#{@site.current_uuid}"
    body.should include('"UUID":')    
  end
  
  it 'should be able to report successfull pull' do
    # create an empty push
    push_request = PushRequest.new
    push_request.success = 1
    push_request.save
    
    # send pull event
    visit "/pull_requests/pull?auth_code=#{@site.auth_code}&current_uuid=#{@site.current_uuid}"
    pull_response_data = JSON.parse(body)
    pull_uuid = pull_response_data['UUID']
    
    # Now, we need to check when the node reports success to the registry for this pull
    visit "/pull_requests/report?auth_code=#{@site.auth_code}&uuid=#{pull_uuid}&success=1"
       
    body.should include('"success":1')
    
    report_response_data = JSON.parse(body)
    # the pull success, so we should have the same UUID in the report response
    report_response_data['uuid'].should == pull_uuid
    # make sure that site.current_uuid has been updated
    report_response_data['uuid'].should == Site.find_by_auth_code("test_123").current_uuid
  end
  
  it 'should not modify site uuid after a failed pull' do
    # create an empty push
    push_request = PushRequest.new
    push_request.success = 1
    push_request.save
    
    # send pull event
    visit "/pull_requests/pull?auth_code=#{@site.auth_code}&current_uuid=#{@site.current_uuid}"
    pull_response_data = JSON.parse(body)
    pull_uuid = pull_response_data['UUID']
    
    # Now, we need to check when the node reports success to the registry for this pull
    visit "/pull_requests/report?auth_code=#{@site.auth_code}&uuid=#{pull_uuid}&success=0"
       
    body.should include('"success":0')
    
    report_response_data = JSON.parse(body)
    Site.find_by_auth_code("test_123").current_uuid == @site.current_uuid
  end
end