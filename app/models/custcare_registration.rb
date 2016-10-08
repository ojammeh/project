class CustcareRegistration < ActiveRecord::Base
	establish_connection :usernames
	self.table_name = "customer_registration"
end
