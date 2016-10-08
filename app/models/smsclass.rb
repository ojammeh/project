class Smsclass < ActiveRecord::Base
	self.table_name = "free_sms_sub"
	establish_connection :jazeera
end
