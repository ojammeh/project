class Boy < ActiveRecord::Base
	self.table_name = "Boy_SUB"
	establish_connection :jazeera
end
