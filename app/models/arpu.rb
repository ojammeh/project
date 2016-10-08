class Arpu < ActiveRecord::Base
	self.table_name = "arpu"
	establish_connection :custcare
end
