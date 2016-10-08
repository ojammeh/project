class Type < ActiveRecord::Base
	establish_connection :cug
	has_many :numbers
end
