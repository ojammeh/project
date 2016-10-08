class AccountNumber < ActiveRecord::Base
	self.table_name = "account_numbers"
	establish_connection :banks
end