class HoroscopeStar < ActiveRecord::Base
	self.table_name = "recycled"
	establish_connection :khavas_linked
end
