class SubscriberRegistration < ActiveRecord::Base
	self.table_name = "subscriber_registration"
	establish_connection :custcare
end
