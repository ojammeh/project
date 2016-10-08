class ActiveSub < ActiveRecord::Base
	self.table_name = "subscriber_tbl"
	establish_connection :msc
end