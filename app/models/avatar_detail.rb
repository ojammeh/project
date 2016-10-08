class AvatarDetail < ActiveRecord::Base
	self.table_name = "details_avatar"
	establish_connection :custcare
end
