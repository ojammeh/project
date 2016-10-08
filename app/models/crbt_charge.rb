class CrbtCharge < ActiveRecord::Base
	self.table_name = "telemar_crbt"
	establish_connection :khavasvas
end
