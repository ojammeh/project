class Subqueue3g < ActiveRecord::Base
	self.table_name = "subqueue_3g"
	establish_connection :gprsbilling
end
