class CdrCollection < ActiveRecord::Base
	self.table_name = "CDR_collection"
	establish_connection :cdrcollection
end
