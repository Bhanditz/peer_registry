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

end
