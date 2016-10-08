class Manifest < ActiveRecord::Base
	establish_connection :usernames
	self.table_name = "sim_manifest"
end
