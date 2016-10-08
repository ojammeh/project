class Number < ActiveRecord::Base
	establish_connection :cug
	# attr_accessor
	# before_save 
	validates :number, presence: true, :uniqueness => true #{message: "Number Exists"}#, length: { maximum: 7, minimum: 7 }
	validates :number, :numericality => {:only_integer => true}, :unless => 'number.blank?'
	belongs_to :cug
	belongs_to :type
end