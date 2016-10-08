class TrackerDate < ActiveRecord::Base
	self.table_name = "tracker_dates"
	establish_connection :custcare
end
