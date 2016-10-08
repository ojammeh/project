class Postpaid < ActiveRecord::Base
	self.table_name = "postpaid"
	establish_connection :gprsbilling
end
