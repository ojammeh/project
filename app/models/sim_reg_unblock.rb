class SimRegUnblock < ActiveRecord::Base
	self.table_name = "delete_Msisdn"
	establish_connection :custcare
end
