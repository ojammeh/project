class Recycled < ActiveRecord::Base
	self.table_name = "recycled"
	establish_connection :custcare
end
