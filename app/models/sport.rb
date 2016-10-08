class Sport < ActiveRecord::Base
	self.table_name = "infocell_sub"
	establish_connection :sport_service
end
