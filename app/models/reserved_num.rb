class ReservedNum < ActiveRecord::Base
	self.table_name = "reserv_num"
	establish_connection :fhvas_direct_sales
end
