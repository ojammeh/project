class Unsubqueue < ActiveRecord::Base
	self.table_name = "unsubscription"
	establish_connection :CRBT
end
