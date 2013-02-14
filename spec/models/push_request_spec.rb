require 'spec_helper'

describe PushRequest do
  
  before (:all) do
    truncate_all_tables
  end

  it 'should generate uuid' do
    PushRequest.gen().uuid.should match(/[a-z0-9]{8}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{12}/)
  end
  
  it 'should return the latest successfull push' do
    push_request = PushRequest.gen(:success => 1)
    PushRequest.latest_successful_push().uuid.should == push_request.uuid
  end
  
  it 'should return a pending push request' do
    PushRequest.gen()
    PushRequest.pending().count.should == 1
  end
end