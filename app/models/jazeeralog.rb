class Jazeeralog < ActiveRecord::Base
	self.table_name = "sub_news_logs"
	establish_connection :in_beast
	self.inheritance_column = nil
end
