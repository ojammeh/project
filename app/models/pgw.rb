class Pgw < ActiveRecord::Base
	self.table_name = "pgw"
	establish_connection :msc
end
