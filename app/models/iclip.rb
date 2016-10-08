class Iclip < ActiveRecord::Base
	self.table_name = "ICLIP"
	establish_connection :iclip
end
