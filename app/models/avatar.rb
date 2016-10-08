class Avatar < ActiveRecord::Base
	#self.table_name = "avatars"
	establish_connection :custcare
end
