class LivefeedSsr < ActiveRecord::Base
	self.inheritance_column = nil
	self.table_name = "ssrs"
	establish_connection :livefeed
end