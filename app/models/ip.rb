class Ip < ActiveRecord::Base
	establish_connection :ip_addresses
end
