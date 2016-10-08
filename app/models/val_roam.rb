class ValRoam < ActiveRecord::Base
	self.table_name = "val_roam"
	establish_connection :tok_cos
end