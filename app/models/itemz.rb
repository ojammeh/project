class Itemz < ActiveRecord::Base
	self.table_name = "items"
	establish_connection :stocks
end
