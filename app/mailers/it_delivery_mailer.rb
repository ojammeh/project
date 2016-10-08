class ItDeliveryMailer < ActionMailer::Base
	include ActionView::Helpers::TextHelper

	self.smtp_settings = {  
      :address              => "192.168.30.254",  
      :port                 => 25,  
      :domain               => "africell.gm",  
      :user_name            => "it-request", #Your user name
      :password             => "it-request", # Your password
      :authentication       => :login, 
      :openssl_verify_mode  => 'none', 
      :enable_starttls_auto => true  
   }

   def new_it_requesting(newitrequest)
  		@newitrequest = newitrequest
  		mail(:from => "it-request@africell.gm", :to => "hdiab@africell.gm,mshuman@africell.gm", :subject => "New IT Request")  
	end
  

	def it_delivery(name,department,requested_by,category,description,quantity,reason,delivered_by,requested_on,delivered_on)
		@name = name
		@department = department
		@requested_by = requested_by
		@category =  category
		@description = description
		@quantity = quantity
		@reason = reason
		@delivered_by = delivered_by
		@requested_on = requested_on
		@delivered_on = delivered_on
		mail(:from => "it-request@africell.gm", :to => "hdiab@africell.gm,mshuman@africell.gm", :subject => "IT Delivery")
	end
end
