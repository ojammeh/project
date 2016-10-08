class TokCos < ActiveRecord::Base
	self.table_name = "tok_cos"
	establish_connection :tok_cos
end
