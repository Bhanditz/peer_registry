require 'spec_helper'

describe PushRequestsController do

  describe "GET 'make_push'" do
    before :each do
      @site = Site.gen(:current_uuid => UUIDTools::UUID.timestamp_create().to_s)
    end

    it "returns http failure when parameters are missing" do
      get 'make_push'
      response.should_not be_success
      response_data = JSON.parse(response.body)
      response_data['message'].should == 'Missing auth_code'
    end

    it "returns http failure when the auth_code is invalid" do
      get 'make_push', :auth_code => 'junk', :current_uuid => 'junk', :file_url => 'junk', :file_md5_hash => 'junk'
      response.should_not be_success
      response_data = JSON.parse(response.body)
      response_data['message'].should == 'Invalid auth_code'
    end

    it "returns http failure when the current_uuid is invalid" do
      get 'make_push', :auth_code => @site.auth_code, :current_uuid => 'junk', :file_url => 'junk', :file_md5_hash => 'junk'
      response.should_not be_success
      response_data = JSON.parse(response.body)
      response_data['message'].should == 'Invalid current_uuid'
    end

    # TODO: this should probably fail - we should validate the availability of the files
    it "returns http success even though file urls aren't right" do
      get 'make_push', :auth_code => @site.auth_code, :current_uuid => @site.current_uuid, :file_url => 'junk', :file_md5_hash => 'junk'
      response.should be_success
      response_data = JSON.parse(response.body)
      response_data['message'].should == 'processing'
    end
  end

  describe "GET 'query'" do
    it "returns http failure when uuid is missing" do
      get 'query'
      response.should_not be_success
      response_data = JSON.parse(response.body)
      response_data['message'].should == 'Missing uuid'
    end

    it "returns http failure when invalid uuid is provided" do
      get 'query', :uuid => 'dasdf'
      response.should_not be_success
      response_data = JSON.parse(response.body)
      response_data['message'].should == 'Invalid uuid'
    end

    it "returns successfull push" do
      p = PushRequest.gen(:success => 1)
      get 'query', :uuid => p.uuid
      response.should be_success
      response_data = JSON.parse(response.body)
      response_data['success'].should == 1
      response_data['success_at'].should == p.success_at.iso8601.to_s
    end
  end
end
