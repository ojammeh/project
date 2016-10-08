class UserMailer < ActionMailer::Base
	#default from: "mmcham@africell.gm"
	include ActionView::Helpers::TextHelper
	
	self.smtp_settings = {  
      :address              => "192.168.30.254",  
      :port                 => 25,  
      :domain               => "africell.gm",  
      :user_name            => "mmcham", #Your user name
      :password             => "cham", # Your password
      :authentication       => :login, 
      :openssl_verify_mode  => 'none', 
      :enable_starttls_auto => true  
   }

  	def new_it_requesting(newitrequest)
  		@newitrequest = newitrequest
  		mail(:from => "mmcham@africell.gm", :to => "mmcham@africell.gm", :subject => "New IT Request")  
	end

	
end
