class TypeOfAccount < ActiveRecord::Base
	#has_many :account_type
	#self.table_name = "africell_banks"
	establish_connection :banks
end