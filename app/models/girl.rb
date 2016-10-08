class Girl < ActiveRecord::Base
	self.table_name = "Girl_SUB"
	establish_connection :jazeera
end
