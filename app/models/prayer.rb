class Prayer < ActiveRecord::Base
	self.table_name = "ramadan_sub"
	establish_connection :jazeera
end
