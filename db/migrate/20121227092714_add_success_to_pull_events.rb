class AddSuccessToPullEvents < ActiveRecord::Migration
  def change
    add_column :pull_events, :success, :integer
  end
end
