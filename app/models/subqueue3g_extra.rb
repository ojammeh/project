class Subqueue3gExtra < ActiveRecord::Base
	self.table_name = "subqueue_3G_extra"
	establish_connection :gprsbilling
end
