class AddFilesToPullEvents < ActiveRecord::Migration
  def change
    add_column :pull_events, :file_url, :string
    add_column :pull_events, :file_md5_hash, :string
  end
end
