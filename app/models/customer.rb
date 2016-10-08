class Customer < ActiveRecord::Base
	establish_connection :usernames
	belongs_to :user
end
