class Supplier < ActiveRecord::Base
	self.table_name = "suppliers"
	establish_connection :banks
end