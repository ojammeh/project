class Complaint < ActiveRecord::Base
	self.table_name = "complaints"
	establish_connection :complaints
end
