class SimReplace < ActiveRecord::Base
	self.table_name = "COS_stk"
	establish_connection :khavasvas
end
