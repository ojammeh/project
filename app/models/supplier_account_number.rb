class SupplierAccountNumber < ActiveRecord::Base
	self.table_name = "supplier_account_numbers"
	establish_connection :banks
end