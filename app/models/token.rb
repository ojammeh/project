class Token < ActiveRecord::Base
	self.table_name = "tokens"
	establish_connection :gprsbilling
end
