class UserOld < ActiveRecord::Base
	self.table_name = "users"
	establish_connection :central_logs
end
