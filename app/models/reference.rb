class Reference < ActiveRecord::Base
	# self.table_name = "b_bans"
	establish_connection :banks
end