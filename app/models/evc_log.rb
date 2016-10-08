class EvcLog < ActiveRecord::Base
	self.table_name = "evc_reverse_logs"
	establish_connection :central_logs
end
