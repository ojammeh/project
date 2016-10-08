class UserLog < ActiveRecord::Base
	self.table_name = "user_logs"
	establish_connection :central_logs
end
