class CynController < ApplicationController

	def cyn_validate
		@msisdn = params[:msisdn]
		session[:msisdn] = params[:msisdn]

		if((@msisdn[0..0] == "7")or(@msisdn[0..0] == "2"))
	 		hlroutput = Hlr.new.execute("DISPLAY","192.167.0.12","BSUWEB","BSU@123","220"+@msisdn,'TRUE',nil,nil,nil,nil,nil,nil,nil,nil)

			if hlroutput.include? "RETCODE = 3001 ERR3001:Subscriber not defined"
				@reserved_numbers = ReservedNum.where(msisdn: @msisdn).first
				if  (@reserved_numbers.blank?)
					@available = "Available"
				elsif @reserved_numbers.status =="Reserved"
					@available = "Reserved"
				elsif @reserved_numbers.status =="Sold"
					@available = "Sold"					
				end
			else
				@available = "Not Available"
			end
			if @available == "Not Available"
				startnum = @msisdn.to_s[0..3]+"%"
				endnum = "%"+@msisdn.to_s[3..6]
				@startoptions = Ha.find_by_sql("SELECT * FROM allmsisdn where MSISDN NOT IN (SELECT MSISDN FROM HUAWEI_HA_SL) AND MSISDN LIKE '#{startnum}'")
				@endoptions = Ha.find_by_sql("SELECT * FROM allmsisdn where MSISDN NOT IN (SELECT MSISDN FROM HUAWEI_HA_SL) AND MSISDN LIKE '#{endnum}'")
			end
		else 
		   flash[:not_africell] = 'Not an Africell number'
		   redirect_to cyn_cyn_select_path and return
	    end

	end

	def reserve
	 	ReservedNum.find_by_sql("insert into reserv_num values('#{session[:msisdn]}','Reserved',getDate())")
	 	UserLog.new(:user => session[:fullname], :transaction_type => "CYN", :description => "CYN Number Reserved", :msisdn => session[:msisdn], :ip_address =>request.remote_ip, :username => session[:username], :created_at => Time.now).save
	  	Custcarelog.new(:msisdn	=> session[:msisdn], :username => session[:username], :full_name => session[:fullname], :department => session[:department], :role => session[:userrole], :transaction_type => "Choose Your Number", :action_performed => "Reserve", :description =>"CYN Number Reserved").save
	  	flash[:reserved] = 'Number Reserved'
	   	redirect_to cyn_cyn_validate_path(:msisdn => session[:msisdn]) and return
   	end

   	def reserving
   		msisdn = params[:msisdn]
	 	ReservedNum.find_by_sql("insert into reserv_num values('#{msisdn}','Reserved',getDate())")
	 	UserLog.new(:user => session[:fullname], :transaction_type => "CYN", :description => "CYN Number Reserved", :msisdn => msisdn, :ip_address =>request.remote_ip, :username => session[:username], :created_at => Time.now).save
	  	Custcarelog.new(:msisdn	=> session[:msisdn], :username => session[:username], :full_name => session[:fullname], :department => session[:department], :role => session[:userrole], :transaction_type => "Choose Your Number", :action_performed => "Reserve", :description =>"CYN Number Reserved").save
	  	flash[:reserved] = 'Number Reserved'
	   	redirect_to cyn_cyn_validate_path(:msisdn => msisdn) and return
   	end

   	def sell
   		iccid = "22002030"+params[:msin]
   		msisdn = "220"+session[:msisdn]
   		msinn = KhavasControl.where(ICCD: iccid)
   		if !msinn.blank?
   			msinn.each do |ims|
				@msin = ims.MSIN
				@a4ki = ims.A4KI
			end	
			a4ki = @a4ki.gsub(/[^0-9A-Za-z]/,'')
			session[:a4] = a4ki
			imsi = "60702"+@msin
			@kioutput = Hlr.new.execute("CREATEAC","192.167.0.12","BSUWEB","BSU@123","1",'SIM',"COMP128_2",imsi,a4ki,"1",nil,nil,nil,nil)
			@createoutput = Hlr.new.execute("CREATESUB","192.167.0.12","BSUWEB","BSU@123","1",imsi,msisdn,"1",nil,nil,nil,nil,nil,nil)
			flash[:reserved] = @createoutput
		else
			flash[:reserved] = 'SIM Range Not Added'
		end

	 	ReservedNum.find_by_sql("update reserv_num set status = 'Sold' where msisdn = '#{session[:msisdn]}'")
	 	Manifest.new(:msisdn =>session[:msisdn], :sim_no => params[:msin], :first_name => params[:fname], :last_name => params[:lname], :role => session[:userrole], :username => session[:username], :id_type => params[:id_type], :id_number => params[:id_number], :nationality => params[:nationality], :agent => session[:fullname]).save
	 	UserLog.new(:user => session[:fullname], :transaction_type => "CYN", :description => "CYN Number Sold", :msisdn => session[:msisdn], :ip_address =>request.remote_ip, :username => session[:username], :created_at => Time.now).save
	  	Custcarelog.new(:msisdn	=> session[:msisdn], :username => session[:username], :full_name => session[:fullname], :department => session[:department], :role => session[:userrole], :transaction_type => "Choose Your Number", :action_performed => "Sell", :description =>"CYN Number Sold").save
		SimRegistration.new(:first_name => params[:fname], :family_name => params[:lname],
			:address => params[:address], :phone => session[:msisdn], :nationality => params[:nationality], :id_type => params[:id_type], 
			:id_number => params[:id_number], :created_at =>Time.now, :sales_person => session[:fullname], :activation_status => 1, :role => session[:userrole]).save
		Hlr.new.execute("UNBLOCKREG","192.167.0.12","BSUWEB","BSU@123",msisdn,'FALSE','PLMN-SS-A',nil,nil,nil,nil,nil,nil,nil)
		Hlr.new.execute("UNBLOCKREG2","192.167.0.12","BSUWEB","BSU@123",msisdn,'NOBIC','NOBOC',nil,nil,nil,nil,nil,nil,nil)
		Hlr.new.execute("UNBLOCKREG3","192.167.0.12","BSUWEB","BSU@123",msisdn,'TRUE',nil,nil,nil,nil,nil,nil,nil,nil)
		Hlr.new.execute("UNBLOCKREG4","192.167.0.12","BSUWEB","BSU@123",msisdn,'COMMON',nil,nil,nil,nil,nil,nil,nil,nil)
		active_sub = ActiveSub.where('subscriber_id =?',session[:msisdn])
		if active_sub.blank?
			Release8.find_by_sql(["EXEC CreateAccount '#{session[:msisdn]}',10,'Default','1234','English','SIM_Reg_AUP'"])
		end
	   	redirect_to cyn_cyn_select_path and return

   	end

end
