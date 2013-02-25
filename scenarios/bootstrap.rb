require Rails.root.join('spec', 'spec_helper.rb')

truncate_all_tables

SyncObjectType.gen(:object_type => "Collection")
SyncObjectType.gen(:object_type => "CollectionItem")
SyncObjectType.gen(:object_type => "Comment")
SyncObjectType.gen(:object_type => "Community")
SyncObjectType.gen(:object_type => "DataObject")
SyncObjectType.gen(:object_type => "Member")
SyncObjectType.gen(:object_type => "Resource")
SyncObjectType.gen(:object_type => "User")
SyncObjectType.gen(:object_type => "Language")

SyncObjectAction.gen(:object_action => "create")
SyncObjectAction.gen(:object_action => "update")
SyncObjectAction.gen(:object_action => "rate")
SyncObjectAction.gen(:object_action => "curate")
SyncObjectAction.gen(:object_action => "delete")
SyncObjectAction.gen(:object_action => "hide")



# Creating MBL's site
mbl = Site.gen(:id => 1, :name => 'MBL', :url => 'http://localhost:3001/')
PullEvent.gen(:site => mbl)
mbl_push = PushRequest.gen(:site => mbl, :success => 1)
# Pushing that User 12345 was created at MBL yesterday
mbl_user_log = PeerLog.gen(:push_request => mbl_push, :user_site => mbl, :user_site_object_id => 12345,
  :sync_object_type => SyncObjectType.find_by_object_type('User'),
  :sync_object_action => SyncObjectAction.find_by_object_action('create'),
  :sync_object_id => 12345,
  :sync_object_site => mbl,
  :action_taken_at_time => 1.day.ago)
LogActionParameter.gen(:peer_log => mbl_user_log,
  :param_object_type => SyncObjectType.find_by_object_type('User'),
  :param_object_id => 12345,
  :param_object_site => mbl,
  :parameter => 'username',
  :value => 'user_12345')
# making the current state of MBL that of the last push
mbl.current_uuid = mbl_push.uuid
mbl.save



# Creating BA's site
ba = Site.gen(:id => 2, :name => 'BA', :url => 'http://localhost:3002/')
# BA pulls MBL's latest changes
PullEvent.gen(:site => ba, :state_uuid => mbl_push.uuid)
ba_push = PushRequest.gen(:site => ba, :success => 1)
# Pushing that User 67890 was created at BA six hours ago
ba_user_log = PeerLog.gen(:push_request => ba_push, :user_site => ba, :user_site_object_id => 67890,
  :sync_object_type => SyncObjectType.find_by_object_type('User'),
  :sync_object_action => SyncObjectAction.find_by_object_action('create'),
  :sync_object_id => 67890,
  :sync_object_site => ba,
  :action_taken_at_time => 6.hours.ago)
LogActionParameter.gen(:peer_log => ba_user_log,
  :param_object_type => SyncObjectType.find_by_object_type('User'),
  :param_object_id => 67890,
  :param_object_site => ba,
  :parameter => 'username',
  :value => 'user_67890')
# making the current state of BA that of the last push
ba.current_uuid = ba_push.uuid
ba.save


# MBL pulls and they are both up-to-date
PullEvent.gen(:site => mbl, :state_uuid => ba_push.uuid)
mbl.current_uuid = ba_push.uuid
mbl.save


