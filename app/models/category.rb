class Category < ActiveRecord::Base
	self.table_name = "category"
	establish_connection :stocks
end