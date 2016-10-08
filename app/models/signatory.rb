class Signatory < ActiveRecord::Base
	# self.table_name = "signatories"
	establish_connection :banks
end