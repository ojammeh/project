class Cug < ActiveRecord::Base
	#self.table_name = "cugs"
	establish_connection :cug
	attr_accessor 
	before_save 
	validates :name, presence: true, length: { minimum: 1 }, allow_blank: true
	validates :monthly_charge, presence: true, length: { maximum: 10 }, allow_blank: true
	has_many :numbers

	accepts_nested_attributes_for :numbers, :reject_if => lambda { |a| a[:content].blank? }, :allow_destroy => true
	before_destroy :remove_numbers
	def remove_numbers
		self.numbers.each do |number|
			number.destroy
		end
		
	end
end

