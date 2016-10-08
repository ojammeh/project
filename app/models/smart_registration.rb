class SmartRegistration < ActiveRecord::Base
	self.table_name = "tbl_registration"
	establish_connection :smart_reg
end
