class Shop < ActiveRecord::Base
	self.table_name = "shops"
	establish_connection :custcare

	validates :msisdn, presence: true, :uniqueness => true, :numericality => {:only_integer => true}, :unless => 'msisdn.blank?'
end
