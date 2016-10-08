class SimRegistrationController < ApplicationController
	
	def search_result
		ndc = params[:msisdn][0..0]
		isdn = params[:msisdn][1..6]
		session[:msisdn] = params[:msisdn]
		@result = SimRegistration.where('phone =? ',params[:msisdn]).order('created_at')
		@smart = SmartRegistration.where(SIMNDC: ndc).where(SIMMSISDN: isdn).where(flag: 1).first
		if @result.blank? and @smart.blank?
			@registered = "false"
		end
		#@count = SimRegistration.where(:phone => params[:msisdn]).count
	end

	def edit
		@editreg = SimRegistration.find(params[:id])
	end

	def update
		@editreg = SimRegistration.find(params[:id])
		if @editreg.update_attributes(update_params)
			flash[:success] = "Data Updated"
			redirect_to :back
			# redirect_to sim_registration_search_path and return
		else
			render 'edit'
		end
	end 
##for PURA
	def sim_reg_result
		#ndc = params[:msisdn][0..0]
		#isdn = params[:msisdn][1..6]
		session[:msisdn] = params[:msisdn]
		@result = RegistrationMain.where('MSISDN =? ',params[:msisdn])
		#@smart = SmartRegistration.where(SIMNDC: ndc).where(SIMMSISDN: isdn).first
		if @result.blank? and @smart.blank?
			@registered = "false"
		end
		#@count = SimRegistration.where(:phone => params[:msisdn]).count
	end

	def new
		dob=(params[:year].to_s + "-" + params[:month].to_s + "-" + params[:day].to_s)

		@blocked = SimRegUnblock.where(msisdn: session[:msisdn]).first
		if !@blocked.blank?
			@blocked.update_attributes(:unblock_status => 0, :register_date => Time.now)
		end

		if session[:userrole] == 'mobile_money_reg'
			SimRegistration.new(:first_name => params[:fname], :family_name => params[:lname], :gender => params[:gender], :birthday_date =>dob, 
			:address => params[:address], :phone => session[:msisdn], :nationality => params[:nationality], :id_type => params[:id_type], 
			:id_number => params[:id_number], :created_at =>Time.now, :sales_person => session[:fullname], :activation_status => 1, :role => session[:userrole], :flag => 3).save
			Custcarelog.new(:msisdn	=> session[:msisdn], :ip => request.remote_ip, :username => session[:username], :full_name => session[:fullname], :department => session[:department],
			 :role => session[:userrole], :transaction_type => "Mobile Money SIM Registration", :action_performed => "Register", :description =>"New SIM Registration").save
		else
			@msisdn = "220"+session[:msisdn]
			#if(session[:username] == 'outletphone1' or session[:username] == 'outletphone1' or session[:username] == 'mkndow' or session[:username] == 'mmcham')
				if params[:shop_num].blank?
					SimRegistration.new(:first_name => params[:fname], :family_name => params[:lname], :gender => params[:gender], :birthday_date =>dob, 
						:address => params[:address], :phone => session[:msisdn], :nationality => params[:nationality], :id_type => params[:id_type], 
						:id_number => params[:id_number], :created_at =>Time.now, :sales_person => session[:fullname], :activation_status => 1, :role => session[:userrole]).save
					Custcarelog.new(:msisdn	=> session[:msisdn], :ip => request.remote_ip, :username => session[:username], :full_name => session[:fullname], 
						:department => session[:department], :role => session[:userrole], :transaction_type => "SIM Registration", :action_performed => "Register", :description =>"New SIM Registration").save
					Hlr.new.execute("UNBLOCKREG","192.167.0.12","BSUWEB","BSU@123",@msisdn,'FALSE','PLMN-SS-A',nil,nil,nil,nil,nil,nil,nil)
					Hlr.new.execute("UNBLOCKREG2","192.167.0.12","BSUWEB","BSU@123",@msisdn,'NOBIC','NOBOC',nil,nil,nil,nil,nil,nil,nil)
					Hlr.new.execute("UNBLOCKREG3","192.167.0.12","BSUWEB","BSU@123",@msisdn,'TRUE',nil,nil,nil,nil,nil,nil,nil,nil)
					Hlr.new.execute("UNBLOCKREG4","192.167.0.12","BSUWEB","BSU@123",@msisdn,'COMMON',nil,nil,nil,nil,nil,nil,nil,nil)
					active_sub = ActiveSub.where('subscriber_id =?',session[:msisdn])
					# if active_sub.blank?
					# 	Release8.find_by_sql(["EXEC CreateAccount '#{session[:msisdn]}',10,'Africell','1234','Default','SIM_Reg_AUP'"])
					# end
					flash[:registered] = 'Registration Successfull'
				else
					shop = Avatar.find_by_sql("select * from shops where msisdn = '#{params[:shop_num]}'")
					if !shop.blank?
						SimRegistration.new(:first_name => params[:fname], :family_name => params[:lname], :gender => params[:gender], :birthday_date =>dob, 
						:address => params[:address], :phone => session[:msisdn], :nationality => params[:nationality], :id_type => params[:id_type], 
						:id_number => params[:id_number], :created_at =>Time.now, :sales_person => session[:fullname], :activation_status => 1, :role => session[:userrole], :shop_number => params[:shop_num]).save
						Custcarelog.new(:msisdn	=> session[:msisdn], :ip => request.remote_ip, :username => session[:username], :full_name => session[:fullname], 
							:department => session[:department], :role => session[:userrole], :transaction_type => "SIM Registration", :action_performed => "Register", :description =>"New SIM Registration").save
						Hlr.new.execute("UNBLOCKREG","192.167.0.12","BSUWEB","BSU@123",@msisdn,'FALSE','PLMN-SS-A',nil,nil,nil,nil,nil,nil,nil)
						Hlr.new.execute("UNBLOCKREG2","192.167.0.12","BSUWEB","BSU@123",@msisdn,'NOBIC','NOBOC',nil,nil,nil,nil,nil,nil,nil)
						Hlr.new.execute("UNBLOCKREG3","192.167.0.12","BSUWEB","BSU@123",@msisdn,'TRUE',nil,nil,nil,nil,nil,nil,nil,nil)
						Hlr.new.execute("UNBLOCKREG4","192.167.0.12","BSUWEB","BSU@123",@msisdn,'COMMON',nil,nil,nil,nil,nil,nil,nil,nil)
						active_sub = ActiveSub.where('subscriber_id =?',session[:msisdn])
						# if active_sub.blank?
						# 	Release8.find_by_sql(["EXEC CreateAccount '#{session[:msisdn]}',10,'Africell','1234','Default','SIM_Reg_AUP'"])
						# end
						flash[:registered] = 'Registration Successfull'
					else
						flash[:registered] = 'Shop Not Available'
					end
				end
			#end
				#client = Savon.client(wsdl: "http://192.168.0.232:8080/axis2/services/WebService?wsdl")
	  			#message = { :operatorName.to_s => 'AUP', :MSISDN.to_s => session[:msisdn], :startBalance => 5, :seriesCOS.to_s => 'Africell', :forename.to_s => params[:fname], :surname.to_s => params[:lname] }
	  			#client.call(:create_enrol_subscriber, message: message)
		end
		redirect_to sim_registration_search_path and return
	end

##for Pura
	def new_registration
		dob=(params[:year].to_s + "-" + params[:month].to_s + "-" + params[:day].to_s)

		@blocked = RegUnblock.where(msisdn: session[:msisdn]).first
		if !@blocked.blank?
			@blocked.update_attributes(:unblock_status => 0, :register_date => Time.now)
		end

		RegistrationMain.new(:Subscriber_Name => params[:fname] +" "+ params[:lname], :MSISDN => session[:msisdn], :Id_Type => params[:id_type], 
			:Id_Num => params[:id_number], :Subscriber_Address => params[:address]).save
		#Custcarelog.new(:msisdn => session[:msisdn], :ip => request.remote_ip, :username => session[:username], :full_name => session[:fullname], :department => session[:department], :role => session[:userrole], :transaction_type => "SIM Registration", :action_performed => "Register", :description =>"New SIM Registration").save
		
		flash[:registered] = 'Registration Successfull'
		redirect_to sim_registration_search_reg_path and return
	end

	def unblockreg
		#msisdn = '"'+ msisdnn + '"'
		@msisdn = "220"+params[:msisdn]
		simreg =  SimRegistration.where(phone: params[:msisdn]).first
		if !simreg.blank?
			Hlr.new.execute("UNBLOCKREG","192.167.0.12","BSUWEB","BSU@123",@msisdn,'FALSE','PLMN-SS-A',nil,nil,nil,nil,nil,nil,nil)
			Hlr.new.execute("UNBLOCKREG2","192.167.0.12","BSUWEB","BSU@123",@msisdn,'NOBIC','NOBOC',nil,nil,nil,nil,nil,nil,nil)
			Hlr.new.execute("UNBLOCKREG3","192.167.0.12","BSUWEB","BSU@123",@msisdn,'TRUE',nil,nil,nil,nil,nil,nil,nil,nil)
			Hlr.new.execute("UNBLOCKREG4","192.167.0.12","BSUWEB","BSU@123",@msisdn,'COMMON',nil,nil,nil,nil,nil,nil,nil,nil)
			#simreg.update_attributes(:activation_status => 0)
			flash[:success] = "Unblock Successfull"
		else
			smartreg = SmartRegistration.find_by_sql("Select * from tbl_registration where SIMNDC+SIMMSISDN = '#{params[:msisdn]}'").first
			if !smartreg.blank?
				Hlr.new.execute("UNBLOCKREG","192.167.0.12","BSUWEB","BSU@123",@msisdn,'FALSE','PLMN-SS-A',nil,nil,nil,nil,nil,nil,nil)
				Hlr.new.execute("UNBLOCKREG2","192.167.0.12","BSUWEB","BSU@123",@msisdn,'NOBIC','NOBOC',nil,nil,nil,nil,nil,nil,nil)
				Hlr.new.execute("UNBLOCKREG3","192.167.0.12","BSUWEB","BSU@123",@msisdn,'TRUE',nil,nil,nil,nil,nil,nil,nil,nil)
				Hlr.new.execute("UNBLOCKREG4","192.167.0.12","BSUWEB","BSU@123",@msisdn,'COMMON',nil,nil,nil,nil,nil,nil,nil,nil)
				#smartreg.update_attributes(:activation_status => 0)
				flash[:success] = "Unblock Successfull"
			end
		end
		if simreg.blank? and smartreg.blank?
			redirect_to sim_registration_search_path and return
		else
			redirect_to sim_registration_unblock_select_path and return
		end
	end

	def reg_count
		date1 = (params[:year1]+params[:month1]+params[:day1]).to_date
    	date2 = (params[:year2]+params[:month2]+params[:day2]).to_date
		@regcount = SimRegistration.find_by_sql("select count(*) as amount,sales_person from sim_registration where (role = 'sim_reg') and (cast (created_at as DATE) BETWEEN '#{date1}' AND '#{date2}') group by sales_person")
	end

	def list_smart
		# ids = SmartRegistration.select("id").first
		@subs = SmartRegistration.where("flag = 0 and createdate < dateadd(HOUR,-1,getdate())").order("CreateDate asc").page(params[:page]).per(100)
		# if !@subs.blank?
		# 	picc1 = @subs.PersonalImage
		# 	picc2 = @subs.IdSide1Image
		# 	picc3 = @subs.IdSide2Image
		# 	pic1 = picc1.gsub!(/\\/, '/')
		# 	pic2 = picc2.gsub!(/\\/, '/')
		# 	pic3 = picc3.gsub!(/\\/, '/')

		# 	@personalpic = 'regimages/'+pic1.split('/')[3]+'/'+pic1.split('/')[-1]+'.jpg'
		# 	@frontpic = 'regimages/'+pic2.split('/')[3]+'/'+pic2.split('/')[-1]+'.jpg'
		# 	@backpic = 'regimages/'+pic3.split('/')[3]+'/'+pic3.split('/')[-1]+'.jpg'
		# 	@regg = 1
		# else
		# 	@regg = 0
		# end
	end

	def show_image
		# @images = Dir.glob("#{Rails.root}/app/assets/images/regimages/20141128/2613797-17-55-49P.jpg")
		ndc = params[:msisdn][0..0]
		isdn = params[:msisdn][1..6]
		@sub = SmartRegistration.where(SIMNDC: ndc).where(SIMMSISDN: isdn).first
		if !@sub.blank?
			picc1 = @sub.PersonalImage
			picc2 = @sub.IdSide1Image
			picc3 = @sub.IdSide2Image
			pic1 = picc1.gsub!(/\\/, '/')
			pic2 = picc2.gsub!(/\\/, '/')
			pic3 = picc3.gsub!(/\\/, '/')

			@personalpic = 'regimages/'+pic1.split('/')[3]+'/'+pic1.split('/')[-1]+'.jpg'
			@frontpic = 'regimages/'+pic2.split('/')[3]+'/'+pic2.split('/')[-1]+'.jpg'
			@backpic = 'regimages/'+pic3.split('/')[3]+'/'+pic3.split('/')[-1]+'.jpg'
			@regg = 1
		else
			@regg = 0
		end
	end

	def view_image
		 # @images = Dir.glob("#{Rails.root}/app/assets/images/regimages/20141128/2613797-17-55-49P.jpg")
		@sub = SmartRegistration.find(params[:id])
		if !@sub.blank?
			picc1 = @sub.PersonalImage
			picc2 = @sub.IdSide1Image
			picc3 = @sub.IdSide2Image
			pic1 = picc1.gsub!(/\\/, '/')
			pic2 = picc2.gsub!(/\\/, '/')
			pic3 = picc3.gsub!(/\\/, '/')

			@personalpic = 'regimages/'+pic1.split('/')[3]+'/'+pic1.split('/')[-1]+'.jpg'
			@frontpic = 'regimages/'+pic2.split('/')[3]+'/'+pic2.split('/')[-1]+'.jpg'
			@backpic = 'regimages/'+pic3.split('/')[3]+'/'+pic3.split('/')[-1]+'.jpg'
			@regg = 1
		else
			@regg = 0
		end
	end

	def validate_smart
		@update = SmartRegistration.find(params[:id])
		@update.update_attributes(:flag => 1, :Validation_date => Time.now, :validated_by => session[:username])
		redirect_to sim_registration_list_smart_path and return
	end

	def invalidate_smart
		@update = SmartRegistration.find(params[:id])
		@update.update_attributes(:flag => 2, :Validation_date => Time.now, :validated_by => session[:username])
		redirect_to sim_registration_list_smart_path and return
	end

	private
	def update_params
			params.require(:sim_registration).permit(:id_type, :id_number)
			
	end
end


