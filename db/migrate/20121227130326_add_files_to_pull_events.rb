class AddFilesToPullEvents < ActiveRecord::Migration
  def change
    add_column :pull_events, :file_url, :string
    add_column :pull_events, :file_md5_hash, :string
    add_column :pull_events, :failed_at, :datetime
    add_column :pull_events, :failed_reason, :string
  end
end
