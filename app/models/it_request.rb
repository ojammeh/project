class ItRequest < ActiveRecord::Base
	self.table_name = "requests"
	establish_connection :it_request
end
