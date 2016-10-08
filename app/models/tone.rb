class Tone < ActiveRecord::Base
	self.table_name = "rings"
	establish_connection :CRBT
end
