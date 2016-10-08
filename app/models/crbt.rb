class Crbt < ActiveRecord::Base
	self.table_name = "subscribers"
	establish_connection :CRBT
end
