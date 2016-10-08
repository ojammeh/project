class Gprsfix < ActiveRecord::Base
	self.table_name = "Sites"
	establish_connection :gprs3g
end
