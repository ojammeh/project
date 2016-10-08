class CosController < ApplicationController
	protect_from_forgery :except => [:create_sim]

	def checkreg
		session[:msisdn] = params[:msisdn]
		@result = SimRegistration.where('phone =? or r_phone=?',params[:msisdn],params[:msisdn])
		@lastreg = SimRegistration.where('phone =? or r_phone=?',params[:msisdn],params[:msisdn]).order('created_at ASC')
		if !@result.blank?
			session[:ifregistered] ="true"
			@lastreg.each do |name|
				flash[:first_name] = "First Name: "+ name.first_name.to_s
				flash[:id_type] = "ID Type: "+ name.id_type.to_s
			end
			redirect_to cos_cos_select_path and return
		else
			redirect_to cos_register_path and return
		end
	end

	def new_registration
		dob=(params[:year].to_s + "-" + params[:month].to_s + "-" + params[:day].to_s)
		SimRegistration.new(:first_name => params[:fname], :family_name => params[:lname], :gender => params[:gender], :birthday_date =>dob, 
			:address => params[:address], :phone => session[:msisdn], :nationality => params[:nationality], :id_type => params[:id_type], 
			:id_number => params[:id_number], :created_at =>Time.now, :sales_person => session[:fullname], :activation_status => 1).save
		flash[:registered] = 'Registration Successfull'
		Custcarelog.new(:msisdn	=> session[:msisdn], :ip => request.remote_ip, :username => session[:username], :full_name => session[:fullname], :department => session[:department], :role => session[:userrole], :transaction_type => "SIM Registration", :action_performed => "Register", :description =>"New SIM Registration").save
		redirect_to cos_cos_check_reg_path and return
	end

	def create_sim
		iccid = "22002030"+params[:msin]
   		msisdnn = "220"+params[:msisdn]
   		msinn = KhavasControl.where(ICCD: iccid).first
   		if !msinn.blank?
			@msin = msinn.MSIN
			@a4ki = msinn.A4KI
			msisdn = '"'+ msisdnn + '"'
			a4ki = @a4ki.gsub(/[^0-9A-Za-z]/,'')
			imsi = "60702"+@msin.to_s
			Hlr.new.execute("CREATEAC","192.167.0.12","BSUWEB","BSU@123","1",'SIM',"COMP128_2",imsi,a4ki,"1",nil,nil,nil,nil)
			create_sim = Hlr.new.execute("ADDIMSI","192.167.0.12","BSUWEB","BSU@123",imsi,msisdn,nil,nil,nil,nil,nil,nil,nil,nil)

			#create new sim
			#create_sim = Hlr.new.execute("CREATESUB","192.167.0.12","BSUWEB","BSU@123","1",imsi,msisdnn,"1",nil,nil,nil,nil,nil,nil)
					
			if create_sim.include? "RETCODE = 0 Operation is successful"
				#SimReplace.new(:msisdn => params[:msisdn], :MSIN => @msin, :ICCID => iccid, :flag => 3, :a4ki => @a4ki, :cos_date => Time.now).save
				#Manifest.new(:msisdn =>params[:msisdn], :sim_no => params[:msin], :first_name => params[:fname], :role => session[:userrole], :username => session[:username], :last_name => params[:lname], :id_type => params[:id_type], :id_number => params[:id_num], :nationality => params[:nationality], :agent => session[:fullname]).save
				UserLog.new(:user => session[:fullname], :transaction_type => "COS", :description => "Create SIM Through Web App", :msisdn => params[:msisdn], :ip_address =>request.remote_ip, :username => session[:username], :created_at => Time.now).save
				Custcarelog.new(:msisdn	=> params[:msisdn], :username => session[:username], :full_name => session[:fullname], :department => session[:department], :role => session[:userrole], :transaction_type => "Change Of SIM", :action_performed => "Create SIM", :description =>"Create SIM Through Web App").save
				Hlr.new.execute("UNBLOCKREG","192.167.0.12","BSUWEB","BSU@123",msisdnn,'FALSE','PLMN-SS-A',nil,nil,nil,nil,nil,nil,nil)
				Hlr.new.execute("UNBLOCKREG2","192.167.0.12","BSUWEB","BSU@123",msisdnn,'NOBIC','NOBOC',nil,nil,nil,nil,nil,nil,nil)
				Hlr.new.execute("UNBLOCKREG3","192.167.0.12","BSUWEB","BSU@123",msisdnn,'TRUE',nil,nil,nil,nil,nil,nil,nil,nil)
				Hlr.new.execute("UNBLOCKREG4","192.167.0.12","BSUWEB","BSU@123",msisdnn,'COMMON',nil,nil,nil,nil,nil,nil,nil,nil)
				active_sub = ActiveSub.where('subscriber_id =?',params[:msisdn])
				# if active_sub.blank?
				# 	Release8.find_by_sql(["EXEC CreateAccount '#{params[:msisdn]}',5,'Africell','1234','Default','SIM_Reg_AUP'"])
				# end
				flash[:success] = create_sim
				redirect_to cos_create_sim_select_path
			else
				flash[:success] = create_sim
				redirect_to cos_create_sim_select_path
			end
		else
			flash[:success] = 'SIM Range Not Added'
			redirect_to cos_create_sim_select_path
		end
	end

	def check_reference

		#session[:registered] = nil
		@msisdn = params[:msisdn]
		session[:msisdn] = params[:msisdn]
		session[:reference1] = params[:ref1]
		session[:reference2] = params[:ref2]
		session[:reference3] = params[:ref3]
		@ref1 = params[:ref1]
		@ref2 = params[:ref2]
		@ref3 = params[:ref3]

		agent = params[:agent]
		msin1 = params[:msin]

			@registered = SimRegistration.where('phone =? or r_phone=?',params[:msisdn],params[:msisdn])
			if !@registered.blank?
				@isregistered = "Registered"
				#session[:registered] = "Registered"
			end

			if params[:check_ref]
				if(@ref1.length > 6 or @ref2.length > 6 or @ref3.length > 6)
					ifpostpaid = Postpaid.where(msisdn: "220"+@msisdn)

					if ifpostpaid.blank?
						
						active_sub = ActiveSub.where('subscriber_id =?',params[:msisdn])
						if !active_sub.blank?
							active_sub.each do |sub|
								@lastt_call = sub.last_call
							end
							if @lastt_call.present?
								@last_call = @lastt_call.to_date
							else
								@last_call = 4.months.ago
							end
						end
						#evc_dealer = ActiveSub.where('subscriber_id =?',"161"+params[:msisdn])
						#if !evc_dealer.blank?
						#	@state = "EVC Dealer"
						if params[:ref1].length == 7
							ref1 = "220"+params[:ref1]
						else
							ref1 = params[:ref1]
						end
						if params[:ref2].length == 7
							ref2 = "220"+params[:ref2]
						else
							ref2 = params[:ref2]
						end
						if params[:ref3].length ==7
							ref3 = "220"+params[:ref3]
						else
							ref3 = params[:ref3]
						end

						if (@ref1 == @ref2 || @ref1 == @ref3 || @ref2 == @ref3)
							flash[:sameref] = 'same references is not allowed'
							redirect_to cos_cos_select_path(:msisdn => @msisdn) and return
						elsif (@ref1 == @msisdn || @ref2 == @msisdn || @ref3v == @msisdn)
							flash[:sameref] = 'Cannot use The Number as reference'
							redirect_to cos_cos_select_path(:msisdn => @msisdn) and return

						elsif(!active_sub.blank? and @last_call >= 75.days.ago)
							@state = "Has Reference"
							@results = Tracker.find_by_sql("EXEC CHKREFNUMBERS '#{@msisdn}','#{ref1}','#{ref2}','#{ref3}'")
							
							@results.each do |result|
								if((@registered.blank?) and (result.resu.to_s[0..0].to_i + result.resu.to_s[1..1].to_i + result.resu.to_s[2..2].to_i >= 2))
									redirect_to cos_register_path and return
								end	
							end
							# if last call is more than 75 days ago
						elsif(!active_sub.blank? and @last_call < 75.days.ago)
							client = Savon.client(wsdl: "http://192.168.0.232:8080/axis2/services/WebService?wsdl")
		  					message = { :operatorName.to_s => 'AUP', :MSISDN.to_s => params[:msisdn] }
		  					response = client.call(:get_account_details, message: message).xml
		  					Nokogiri::HTML(response).root.children.each do |node|
								@valid_status = node.at_css('cos').content
							end

							valroam = ValRoam.where(msisdn: session[:msisdn])
							if !valroam.blank?
								valroam.each do |roam|
									@roam_status = roam.update_type
								end
								if(@roam_status == 3)
									@roamm_status = "Active"
								elsif(@roam_status == 4)
									@validd_status = "Active"
								end
							end
							@registered.each do |register|
								@first_name = register.first_name
								@id_type = register.id_type
								@id_number = register.id_number
							end
							tokens = Token.where(msisdn: "220"+params[:msisdn])
					
							if(@valid_status == "Africell validity" or @validd_status == "Active")
								@state = "Validity"
							elsif(@valid_status == "Roaming" or @roamm_status == "Active")
								@state = "Roaming"
							elsif(@valid_status != "Roaming" or @roamm_status != "Active" or @valid_status != "Africell validity" or @validd_status != "Active")
								@state = "SMS Generated"
							elsif !tokens.blank?
								tokens.each do |token|
									@status = token.status
								end
								if(@status != 6)
									@state = "Data Usage"
								end
							else
								@state = "SMS Generated"
							end
							#redirect_to cos_cos_select_path(:msisdn => @msisdn) and return

						elsif(active_sub.blank?)
							hlroutput = Hlr.new.execute("DISPLAY","192.167.0.12","BSUWEB","BSU@123","220"+@msisdn,'TRUE',nil,nil,nil,nil,nil,nil,nil,nil)						
							if hlroutput.include? "RETCODE = 0 SUCCESS0001:Operation is successful"
								@state = "Recycled"
							else
								@state = "Number does not exist or on CYN"
							end
							#redirect_to cos_cos_select_path(:msisdn => @msisdn) and return
						end
					else
						@state ="PostPaid"
						flash[:postpaid] = 'Cannot Replace Pospaid Number'
						redirect_to cos_cos_select_path(:msisdn => @msisdn) and return
					end
				else
					flash[:sameref] = 'Referece Should be at least 7 digits'
					redirect_to cos_cos_select_path
				end	

			elsif params[:confirm_id]
				@msisdn = params[:msisdn]
				@idnumber = params[:id_num]
				results = SimRegistration.where('phone =? or r_phone=?',params[:msisdn],params[:msisdn])
				if !results.blank?
					results.each do |reg|
						@idnum = reg.id_number
					end
					id_a = params[:id_num].gsub(/[^0-9A-Za-z]/,'')
					id_b = @idnum.gsub(/[^0-9A-Za-z]/,'')
					if id_a != id_b
						@state = "IDs Do Not Match"
					elsif id_a == id_b
						@state = "IDs Match"	
					end
				else
					@state = "Not Registered"
				end

			elsif params[:create_sim]
				iccid = "22002030"+params[:msin]
		   		msisdnn = "220"+params[:msisdn]
		   		msinn = KhavasControl.where(ICCD: iccid)
		   		if !msinn.blank?
		   			msinn.each do |ims|
						@msin = ims.MSIN
						@a4ki = ims.A4KI
					end
					msisdn = '"'+ msisdnn + '"'
					a4ki = @a4ki.gsub(/[^0-9A-Za-z]/,'')
					imsi = "60702"+@msin.to_s
					Hlr.new.execute("CREATEAC","192.167.0.12","BSUWEB","BSU@123","1",'SIM',"COMP128_2",imsi,a4ki,"1",nil,nil,nil,nil)
					create_sim = Hlr.new.execute("ADDIMSI","192.167.0.12","BSUWEB","BSU@123",imsi,msisdn,nil,nil,nil,nil,nil,nil,nil,nil)
					
					if create_sim.include? "RETCODE = 0 Operation is successful"
						SimReplace.new(:msisdn => params[:msisdn], :MSIN => @msin, :ICCID => iccid, :flag => 3, :a4ki => @a4ki, :cos_date => Time.now).save
						Manifest.new(:msisdn =>params[:msisdn], :sim_no => params[:msin], :first_name => params[:fname], :role => session[:userrole], :username => session[:username], :last_name => params[:lname], :id_type => params[:id_type], :id_number => params[:id_num], :nationality => params[:nationality], :agent => session[:fullname]).save
						UserLog.new(:user => session[:fullname], :transaction_type => "COS", :description => "Create SIM Through Web App", :msisdn => params[:msisdn], :ip_address =>request.remote_ip, :username => session[:username], :created_at => Time.now).save
						Custcarelog.new(:msisdn	=> params[:msisdn], :username => session[:username], :full_name => session[:fullname], :department => session[:department], :role => session[:userrole], :transaction_type => "Change Of SIM", :action_performed => "Create SIM", :description =>"Create SIM Through Web App").save
						Hlr.new.execute("UNBLOCKREG","192.167.0.12","BSUWEB","BSU@123",msisdn,'FALSE','PLMN-SS-A',nil,nil,nil,nil,nil,nil,nil)
						Hlr.new.execute("UNBLOCKREG2","192.167.0.12","BSUWEB","BSU@123",msisdn,'NOBIC','NOBOC',nil,nil,nil,nil,nil,nil,nil)
						Hlr.new.execute("UNBLOCKREG3","192.167.0.12","BSUWEB","BSU@123",msisdn,'TRUE',nil,nil,nil,nil,nil,nil,nil,nil)
						Hlr.new.execute("UNBLOCKREG4","192.167.0.12","BSUWEB","BSU@123",msisdn,'COMMON',nil,nil,nil,nil,nil,nil,nil,nil)
						# Release8.find_by_sql(["EXEC CreateAccount '#{params[:msisdn]}',5,'Africell','1234','Default','SIM_Reg_AUP'"])

						flash[:success] = create_sim
						redirect_to cos_cos_select_path
					else
						flash[:success] = create_sim
						redirect_to cos_cos_select_path
					end
				else
					flash[:success] = 'SIM Range Not Added'
					redirect_to cos_cos_select_path
				end
					
			elsif params[:replace]
				#get msin and a4ki by querying Msin_Iventory on Khavas
				iccid = "22002030"+params[:msin]
		   		msisdnn = "220"+params[:msisdn]
		   		msinn = KhavasControl.where(ICCD: iccid)
		   		if !msinn.blank?
		   			msinn.each do |ims|
						@msin = ims.MSIN
						@a4ki = ims.A4KI
					end
					msisdn = '"'+ msisdnn + '"'
					a4ki = @a4ki.gsub(/[^0-9A-Za-z]/,'')
					imsi = "60702"+@msin.to_s
					Hlr.new.execute("CREATEAC","192.167.0.12","BSUWEB","BSU@123","1",'SIM',"COMP128_2",imsi,a4ki,"1",nil,nil,nil,nil)
					create_sim = Hlr.new.execute("ADDIMSI","192.167.0.12","BSUWEB","BSU@123",imsi,msisdn,nil,nil,nil,nil,nil,nil,nil,nil)
					
					if create_sim.include? "successful"
						changesim = SimReplace.new(:msisdn => params[:msisdn], :MSIN => @msin, :ICCID => iccid, :Ref1 => @ref1, :Ref2 => @ref2, :Ref3 => @ref3, :flag => 3, :a4ki => @a4ki, :cos_date => Time.now).save
						sim_manifest = Manifest.new(:msisdn => params[:msisdn], :sim_no => params[:msin], :first_name => params[:fname], :role => session[:userrole], :username => session[:username], :last_name => params[:lname], :id_type => params[:id_type], :id_number => params[:id_number], :nationality => params[:nationality], :agent => session[:fullname]).save
						UserLog.new(:user => session[:fullname], :transaction_type => "COS", :description => "Change of SIM Through Web App", :msisdn => params[:msisdn], :ip_address =>request.remote_ip, :username => session[:username], :created_at => Time.now).save
						Custcarelog.new(:msisdn	=> params[:msisdn], :username => session[:username], :full_name => session[:fullname], :department => session[:department], :role => session[:userrole], :transaction_type => "Change Of SIM", :action_performed => "Change Of SIM", :description =>"Change of SIM Through Web App").save
						flash[:success] = create_sim
						redirect_to cos_cos_select_path
					else
					flash[:success] = create_sim
					redirect_to cos_cos_select_path
					end
				else
			 		flash[:success] = 'SIM Range Not Added'
					redirect_to cos_cos_select_path
				end
			end
		
	end
end
