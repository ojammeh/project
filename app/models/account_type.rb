class AccountType < ActiveRecord::Base
	belongs_to :africell_bank
	#self.table_name = "account_types"
	establish_connection :banks
end