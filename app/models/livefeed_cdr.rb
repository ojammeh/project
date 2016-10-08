class LivefeedCdr < ActiveRecord::Base
	self.inheritance_column = nil
	self.table_name = "cdrs"
	establish_connection :livefeedcdr
end