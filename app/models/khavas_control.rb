class KhavasControl < ActiveRecord::Base
	self.table_name = "MSIN_Inventory"
	establish_connection :khavascontrol
end
