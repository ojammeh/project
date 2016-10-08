class SupplierBank < ActiveRecord::Base
	self.table_name = "supplier_banks"
	establish_connection :banks
end