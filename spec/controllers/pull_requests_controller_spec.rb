require 'spec_helper'

describe PullRequestsController do

  describe "GET 'pull'" do
    before :each do
      @site = Site.gen(:current_uuid => UUIDTools::UUID.timestamp_create().to_s)
    end

    it "returns http failure when parameters are missing" do
      get 'pull'
      response.should_not be_success
      response_data = JSON.parse(response.body)
      response_data['message'].should == 'Missing auth_code'
    end

    it "returns http failure when the auth_code is invalid" do
      get 'pull', :auth_code => 'junk', :current_uuid => 'junk'
      response.should_not be_success
      response_data = JSON.parse(response.body)
      response_data['message'].should == 'Invalid auth_code'
    end

    it "returns http failure when the current_uuid is invalid" do
      get 'pull', :auth_code => @site.auth_code, :current_uuid => 'junk'
      response.should_not be_success
      response_data = JSON.parse(response.body)
      response_data['message'].should == 'Invalid current_uuid'
    end

    it "returns http failure when the site aleady has pending pulls" do
      PullEvent.gen(:site => @site, :success_at => nil)
      get 'pull', :auth_code => @site.auth_code, :current_uuid => @site.current_uuid
      response.should_not be_success
      response_data = JSON.parse(response.body)
      response_data['message'].should == 'Another pull is in progress'
    end

    it "returns http failure when there are no push events in the system" do
      get 'pull', :auth_code => @site.auth_code, :current_uuid => @site.current_uuid
      response.should_not be_success
      response_data = JSON.parse(response.body)
      response_data['message'].should == 'Nothing to pull'
    end

    it "returns http failure when the site is at the latest push event" do
      push = PushRequest.gen(:site => @site)
      @site.update_column('current_uuid', push.uuid)
      get 'pull', :auth_code => @site.auth_code, :current_uuid => push.uuid
      response.should_not be_success
      response_data = JSON.parse(response.body)
      response_data['message'].should == 'Nothing to pull'
    end

    # TODO: I don't really think many of these should generate failures - we need
    # a standard way to generate a JSON reponse for a successful, but uneventful request
    it "returns http failure when the site is at the latest push event" do
      push = PushRequest.gen(:site => @site)
      @site.update_column('current_uuid', push.uuid)
      get 'pull', :auth_code => @site.auth_code, :current_uuid => push.uuid
      response.should_not be_success
      response_data = JSON.parse(response.body)
      response_data['message'].should == 'Nothing to pull'
    end

    it "should process a pull and return the proper results" do
      push = PushRequest.gen(:site => @site)
      @site.update_column('current_uuid', push.uuid)

      other_site = Site.gen
      other_site_push = PushRequest.gen(:site => other_site)
      other_site.update_column('current_uuid', other_site_push.uuid)
      peer_log1 = PeerLog.gen(:push_request => other_site_push)
      peer_log2 = PeerLog.gen(:push_request => other_site_push)

      get 'pull', :auth_code => @site.auth_code, :current_uuid => @site.current_uuid
      response.should be_success
      response_data = JSON.parse(response.body)
      pull_event = PullEvent.last
      response_data['file_url'].ends_with?("/files/#{pull_event.id}.json").should == true
      response_data['file_md5_hash'].ends_with?("/files/#{pull_event.id}.md5").should == true
      response_data['UUID'].should == pull_event.state_uuid

      file_path = File.join(Rails.root, 'public', 'files', "#{pull_event.id}.json");
      md5_path = File.join(Rails.root, 'public', 'files', "#{pull_event.id}.md5");
      file_contents = File.read(file_path);
      file_json = JSON.parse(file_contents);
      md5_contents = File.read(md5_path);

      md5_contents.should == Digest::MD5.hexdigest(file_contents)
      file_json[0]['user_site_id'].should == peer_log1.user_site_id
      file_json[0]['sync_object_action'].should == peer_log1.sync_object_action.object_action
      file_json[0]['sync_object_type'].should == peer_log1.sync_object_type.object_type

      file_json[1]['user_site_id'].should == peer_log2.user_site_id
      file_json[1]['sync_object_action'].should == peer_log2.sync_object_action.object_action
      file_json[1]['sync_object_type'].should == peer_log2.sync_object_type.object_type
    end
  end
end
