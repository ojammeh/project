class RegistrationMain < ActiveRecord::Base
	self.table_name = "registration_main"
	establish_connection :custcare
end
