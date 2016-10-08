class Sms < ActiveRecord::Base
	self.table_name = "web_sms"
	establish_connection :web2sms
end