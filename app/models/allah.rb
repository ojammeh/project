class Allah < ActiveRecord::Base
	self.table_name = "allaname_sub"
	establish_connection :jazeera
end
