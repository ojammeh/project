class Site < ActiveRecord::Base
	establish_connection :live_CDR
end
