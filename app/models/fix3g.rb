class Fix3g < ActiveRecord::Base
	self.table_name = "sub_current_status"
	establish_connection :gprsbilling
end
