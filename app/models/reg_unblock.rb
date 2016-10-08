class RegUnblock < ActiveRecord::Base
	self.table_name = "deactivation"
	establish_connection :custcare
end
