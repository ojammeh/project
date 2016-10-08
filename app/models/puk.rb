class Puk < ActiveRecord::Base
	self.table_name = "Inkript"
	establish_connection :msc
end
