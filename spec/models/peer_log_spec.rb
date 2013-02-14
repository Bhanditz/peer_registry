require 'spec_helper'

describe PeerLog do
  
  before :all do
    truncate_all_tables
  end
  
  it 'should have a pending pull for a site' do
    site = Site.gen(:auth_code => "test_123")
    # create an empty push
    push_request = PushRequest.new
    push_request.site_id = site.id
    push_request.success = 1
    push_request.save
    
    uuid = push_request.uuid

    # assign the new uuid to the site
    site.current_uuid = uuid
    site.save
    # create a new site
    new_site = Site.gen(:current_uuid => push_request.uuid)
    
    # create an empty push for new_site
    push_request = PushRequest.new
    push_request.success = 1
    push_request.site_id = new_site.id
    push_request.save
    
    PeerLog.gen(:push_request => push_request)
    
    # Now, there should be a pending pull for site 1
    PeerLog.new_logs_for_site(site).count.should == 1
  end
  
  pending "a check to test the function PeerLog.combine_logs_in_one_json"
end
