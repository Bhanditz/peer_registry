class LogActionParameter < ActiveRecord::Base
  attr_accessible :param_object_id, :param_object_site_id, :param_object_type_id, :parameter, :peer_log_id, :value

  belongs_to :param_object_type, :class_name => 'SyncObjectType', :foreign_key => :param_object_type_id
  belongs_to :param_object_site, :class_name => 'Site', :foreign_key => :param_object_site_id
  belongs_to :peer_log
end
