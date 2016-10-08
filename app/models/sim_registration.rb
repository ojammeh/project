class SimRegistration < ActiveRecord::Base
	self.table_name = "sim_registration"
	establish_connection :custcare
end
