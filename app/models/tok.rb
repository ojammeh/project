class Tok < ActiveRecord::Base
	self.table_name = "FriendsAndFamily"
	establish_connection :khavasvas
end