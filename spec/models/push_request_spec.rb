require 'spec_helper'

describe PushRequest do
  
  before (:all) do
    truncate_all_tables
  end

  it 'should generate uuid' do
    PushRequest.gen().uuid.should match(/[a-z0-9]{8}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{12}/)
  end

end