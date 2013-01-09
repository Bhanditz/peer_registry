require 'spec_helper'

describe PullRequestsController do

  describe "GET 'pull'" do
    it "returns http success" do
      get 'pull'
      response.should be_success
    end
  end

end
