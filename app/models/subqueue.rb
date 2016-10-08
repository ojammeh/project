class Subqueue < ActiveRecord::Base
	self.table_name = "subqueue"
	establish_connection :CRBT
end
