class DirectSale < ActiveRecord::Base
	self.table_name = "Directsales_Act"
	establish_connection :custcare
end
