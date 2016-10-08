class DirectTeam < ActiveRecord::Base
	self.table_name = "direct_teams"
	establish_connection :custcare
end
