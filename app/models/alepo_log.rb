class AlepoLog < ActiveRecord::Base
	self.table_name = "Purchase_3G_logs"
	establish_connection :gprsbilling133
end
