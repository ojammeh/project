class Cugmailer < ActionMailer::Base
	include ActionView::Helpers::TextHelper
	
	self.smtp_settings = {  
      :address              => "192.168.30.254",  
      :port                 => 25,  
      :domain               => "africell.gm",  
      :user_name      		=> 'cug@africell.gm',
  	  :password       		=> 'ma1icu9l',
      :authentication       => :login, 
      :openssl_verify_mode  => 'none', 
      :enable_starttls_auto => true  
   }

  def new_cug(cug)
      @cug = cug
      mail(:from => "cug@africell.gm", :to => "esaidy@africell.gm,mmcham@africell.gm,fmjobe@africell.gm", :subject => "New CUG")  

  end
	
  def prepaid_mailer(prepaid_num,cugname,postpaid_num)
      @prepaid_num = prepaid_num
      @postpaid_num = postpaid_num
      @cugname = cugname
      mail(:from => "cug@africell.gm", :to => "esaidy@africell.gm,fmjobe@africell.gm", :subject => "Numbers Added to #{@cugname} CUG")  
  end

  def postpaid_mailer(postpaid_num,cugname,prepaid_num)
      @postpaid_num = postpaid_num
      @prepaid_num = prepaid_num
      @cugname = cugname
      mail(:from => "cug@africell.gm", :to => "mmcham@africell.gm,fmjobe@africell.gm", :subject => "Numbers Added to #{@cugname} CUG")  
  end

  def delete_number(delnum)
      @delnum = delnum
      mail(:from => "cug@africell.gm", :to => "esaidy@africell.gm,mmcham@africell.gm", :subject => "Number Delete From #{@cugname} CUG")  
  end
  def delete_cug(delcug)
      @delcug = delcug
      mail(:from => "cug@africell.gm", :to => "esaidy@africell.gm,mmcham@africell.gm,fmjobe@africell.gm", :subject => "Delete Entire #{@cugname} CUG")  
  end
end
