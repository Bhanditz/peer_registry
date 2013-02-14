require 'spec_helper'

describe Site do

  before (:all) do
    truncate_all_tables
  end

  it 'should authenticate a site' do
    site = Site.gen(:auth_code => "test_123")
    Site.authenticate("test_123").should_not be_nil
  end

  it 'should generate auth_code' do
    Site.gen.auth_code.should match(/[a-z0-9]{8}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{12}/)
  end
  
  it 'should mark a site as up to date' do
    site = Site.gen(:auth_code => "test_123")
    # create an empty push
    push_request = PushRequest.new
    push_request.success = 1
    push_request.save
    
    uuid = push_request.uuid

    # assign the new uuid to the site
    site.current_uuid = uuid
    site.save
    
    site.up_to_date?.should be_true
    
    new_site = Site.gen(:current_uuid => push_request.uuid)
    
    # create an empty push
    push_request = PushRequest.new
    push_request.success = 1
    push_request.site_id = new_site.id
    push_request.save
    
    site.up_to_date?.should be_false
  end
  
end
