class PrintLog < ActiveRecord::Base
	validates :id, :uniqueness => :true
	# self.table_name = "print_logs"
	establish_connection :banks
end