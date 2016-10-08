class Ha < ActiveRecord::Base
	self.table_name = "HUAWEI_HA_SL"
	establish_connection :msc
end
