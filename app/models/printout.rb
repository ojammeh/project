class Printout < ActiveRecord::Base
	self.inheritance_column = nil
	self.table_name = "vw_ssrs"
	establish_connection :livefeed
end