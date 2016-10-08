class CashierProduct < ActiveRecord::Base
	self.table_name = "products"
	establish_connection :receipts
end
