class BBan < ActiveRecord::Base
	# self.table_name = "b_bans"
	establish_connection :banks
end