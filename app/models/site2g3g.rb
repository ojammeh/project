class Site2g3g < ActiveRecord::Base
	self.table_name = "Sites2g3g"
	establish_connection :gprsbill
end