class Jazeera < ActiveRecord::Base
	self.table_name = "News_Sub"
	establish_connection :jazeera
end
