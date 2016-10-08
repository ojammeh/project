class Horoscope < ActiveRecord::Base
	self.table_name = "horoscope_sub"
	establish_connection :khavasvas
end
