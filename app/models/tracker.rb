class Tracker < ActiveRecord::Base
	self.table_name = "viewCDR201405_imei_tracker"
	establish_connection :live_CDR
end
