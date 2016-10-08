class CustomercareController < ApplicationController
	protect_from_forgery :except => [:vas_actions, :add_details]

	def check_registration
		session[:consumption] = nil
		session[:msisdn] = params[:msisdn].to_s

		registration = SimRegistration.where(phone: params[:msisdn])
		custcareregistration = CustcareRegistration.where(msisdn: params[:msisdn])
		if(!registration.blank? or !custcareregistration.blank?)
			redirect_to customercare_vas_path(:msisdn => session[:msisdn]) and return
		end
	end

	def add_details
		msisdn = session[:msisdn]
		CustcareRegistration.new(:msisdn => session[:msisdn], :first_name => params[:f_name], :last_name => params[:l_name], :id_type => params[:id_type], :id_number => params[:id_number], :custcare_agent => session[:fullname]).save
		redirect_to customercare_vas_path(:msisdn => msisdn) and return
	end

	def vas
		ifpostpaid = Postpaid.where(msisdn: "220"+session[:msisdn])
		if ifpostpaid.blank?
			@postpaid = "Prepaid"
			session[:postpaid] = @postpaid
		else
			@postpaid = "Postpaid"
			session[:postpaid] = @postpaid
		end

		if(@postpaid == "Prepaid")

			client = Savon.client(wsdl: "http://192.168.0.232:8080/axis2/services/WebService?wsdl")
		  	message = { :operatorName.to_s => 'AUP', :MSISDN.to_s => session[:msisdn].to_s }
		  	response = client.call(:get_account_details, message: message).xml
		  	Nokogiri::HTML(response).root.children.each do |node|
				@credit = node.at_css('balance').content.to_i
				@cosvalid_status = node.at_css('cos').content
			end

				if(@credit >= 5)
					@credit_balance = "Credit Balance: Above 5 Dalasis"
				elsif(@credit > 0 and @credit < 5)
					@credit_balance = "Credit Balance: Between 0 and 5 Dalasis"
				elsif(@credit == 0)
					@credit_balance = "Credit Balance: 0 Dalasis"
				elsif(@credit < 0 )
					@credit_balance = "Credit Balance: Negative Balance"
				end
				session[:credit_balance] = @credit
		end

		crbt = Crbt.where('msisdn =? and HaveRings =? and flagSubscription =?', "220"+session[:msisdn], 1, 0)
		if !crbt.blank?
			@crbt_status = "Active"
			crbt.each do |date|
				@sub_date = date.Subscription_Date
			end
		else
			@crbt_status = "Inactive"
			crbt.each do |date|
				@sub_date = date.Subscription_Date
			end
		end

		jazeera = Jazeera.where(msisdn: session[:msisdn])
		if !jazeera.blank?
			@jazeera_status = "Active"
			jazeera.each do |date|
				@jazeera_date = date.reg_date
			end
		else
			@jazeera_status = "Inactive"
		end

		smsclass = Smsclass.where(msisdn: session[:msisdn])
		if !smsclass.blank?
			@smsclass_status = "Active"
			smsclass.each do |date|
				@smsclass_date = date.start_date
			end
		else
			@smsclass_status = "Inactive"
		end

		#sport = Sport.where(msisdn: session[:msisdn])
		#if !sport.blank?
		#	@sport_status = "Active"
		#	sport.each do |date|
		#		@sport_date = date.reg_date
		#	end
		#else
		#	@sport_status = "Inactive"
		#end

		prayertime = Prayer.where(msisdn: session[:msisdn])
		if !prayertime.blank?
			@prayertime_status = "Active"
			prayertime.each do |date|
				@prayertime_date = date.reg_date
			end
		else
			@prayertime_status = "Inactive"
		end

		#names = Allah.where(msisdn: session[:msisdn])
		#if !names.blank?
		#	@names_status = "Active"
		#	names.each do |date|
		#		@names_date = date.reg_date
		#	end
		#else
		#	@names_status = "Inactive"
		#end

		boy = Boy.where(msisdn: session[:msisdn])
		if !boy.blank?
			@boy_status = "Active"
			boy.each do |date|
				@boy_date = date.reg_date
			end
		else
			@boy_status = "Inactive"
		end

		girl = Girl.where(msisdn: session[:msisdn])
		if !girl.blank?
			@girl_status = "Active"
			girl.each do |date|
				@girl_date = date.reg_date
			end
		else
			@girl_status = "Inactive"
		end

		#query = "select * from openquery(KHAVAS_CONTROL,'select * from vas.dbo.horoscope_sub where msisdn = ''#{session[:msisdn]}''')"
		horoscope = Linkedserver.find_by_sql("select * from openquery(KHAVAS_CONTROL,'select * from VAS.dbo.horoscope_sub where msisdn = ''#{session[:msisdn]}''')")
		if !horoscope.blank?
			@horoscope_status = "Active"
			horoscope.each do |date|
				@horoscope_date = date.reg_date
			end
		else
			@horoscope_status = "Inactive"
		end

		tok = Tok.where(msisdn: session[:msisdn])
		if !tok.blank?
			@active_faf = "true"
			tok.each do |date|
				@tok_start_date = date.reg_date
				@tok_end_date = date.end_date
			end
		end

		iclip = Linkedserver.find_by_sql("select * from openquery(iclip,'select * from dbo.ICLIP where PHONENUMBER = ''#{session[:msisdn]}''')")
		if !iclip.blank?

			iclip.each do |date|
				@date1 = date.STARTDATE
				@date2 = date.ENDDATE
			end
			subdate = (@date1[4..7] +'-'+ @date1[2..3] + '-'+ @date1[0..1]).to_date
			enddate = (@date2[4..7] +'-'+ @date2[2..3] + '-'+ @date2[0..1]).to_date
			@iclip_date = subdate
			if(Date.today < enddate)
				@iclip_status = "Active"
			else
				@iclip_status = "Inactive"
			end
		else
			@iclip_status = "Inactive"
		end

		if @cosvalid_status == "Africell validity"
			validity = ValRoam.where(msisdn: session[:msisdn]).where(update_type: 4).first
			@validity_status = "Active"
			if !validity.blank?
				@exp_date = validity.expiry_date
			end
		else
			@validity_status = "Inactive"
		end
		if @cosvalid_status == "Roaming"
			roaming = ValRoam.where(msisdn: session[:msisdn]).where(update_type: 3).first
			@roaming_status = "Active"
			if !roaming.blank?
				@exp_date = roaming.expiry_date
			end
		else
			@roaming_status = "Inactive"
		end


		# kolareh = Linkedserver.find_by_sql(["EXEC CDN...GetAccount_loyalty '#{session[:msisdn]}'"])
		# 	kolareh.each do |kol|
		# 		@kolstatus = kol.Loyalty_status
		# 	end
		# 	if(@kolstatus == "Y")
		# 		@kolareh_status = "Active"
		# 	else
		# 		@kolareh_status = "Inactive"
		# 	end


		client = Savon.client(wsdl: "http://192.168.0.232:8080/axis2/services/WebService?wsdl")
		message = { :operatorName.to_s => 'AUP', :MSISDN.to_s => session[:msisdn].to_s }
		response = client.call(:list_ff_numbers, message: message).xml
		Nokogiri::HTML(response).root.children.each do |node|
			if node.at_css('ffnumber')
				@tok_status = "Active"
				@tok_number = node.at_css('ffnumber').content
				@alreadyactive = "true"

				@show_call_time = Tok.find_by_sql(["EXEC fandFproc_NEW '#{session[:msisdn]}','#{@tok_number}'"])

				@show_call_time.each do |duration|
					@call_duration = duration.total
	 			end
			else
				@tok_status = "Inactive"
			end

		end
		# @active_tok = Tok.find_by_sql("select * from openquery(CDN,'SELECT ff_phone_number FROM dbo.db_sub_friends_family_tbl WHERE subscriber_id = ''#{session[:msisdn]}''')")
		# 	if !@active_tok.blank?
		# 		@tok_status = "Active"
		# 		@active_tok.each do |toknum|
		# 			@tok_number = toknum.ff_phone_number
		# 			@alreadyactive = "true"
		# 			@talktime = Tok.find_by_sql("EXEC fandFproc '#{session[:msisdn]}','#{@tok_number}'")
		# 			#@talktime = Tok.fetch_val_from_sp("EXEC fandFproc '#{session[:msisdn]}','#{@tok_number}'")
		# 			@talktime.each do |duration|
		# 				@call_duration = duration.CALL_DUR
		# 			#@call_duration = "N/A"
		# 			end
		# 		end
		# 	else
		# 		@tok_status = "Inactive"
		# 	end
		isdn = "220"+session[:msisdn]
		#token = Token.find_by_sql("select * from tokens where msisdn = #{isdn}").first
		# if !token.blank?
			# @tokenexist = "true"
			# @token = token.balance_tokens
		# @purchased = AlepoLog.find_by_sql("SELECT top 3 * FROM [dbo].[Purchase_3G_logs] WHERE anumber ='#{isdn}' and bnumber is null ORDER BY purchase_date DESC")
		# @extra = AlepoLog.find_by_sql("SELECT top 3 * FROM [dbo].[Purchase_3G_logs] WHERE bnumber ='#{isdn}' ORDER BY purchase_date DESC")
		@purchased = AlepoLog.where(anumber: isdn).where(bnumber: nil).order("purchase_date DESC").limit(3)
		@extra = AlepoLog.where(bnumber: isdn).order("purchase_date DESC").limit(3)
		url = "http://192.168.0.132:3000/api/africellgm/get_balance?subscriber_id=#{isdn}"
		response = HTTParty.get(url).parsed_response.to_xml
		doc = Nokogiri::XML(response)
		doc.xpath("//output").each do |node|
			@expiry = node.at('expiry').content.to_date
			@token = node.at('balance').content.to_f.round(2)				
		end
		@account_history = LivefeedSsr.find_by_sql("SELECT TOP 3 * FROM [dbo].[ssrs] WHERE opid like '3G_USSD%' and accnum ='#{session[:msisdn]}' ORDER BY time DESC")
		if !@account_history.blank?
			@purchasedd = "true"
		end
			#@purchased = Token.find_by_sql("SELECT max(purchase_date) from vas1.vas.dbo.subqueue_3gbkp WHERE msisdn = '#{session[:msisdn]}' ORDER BY purchase_date DESC")
		#end
		#check_trans = Token.find_by_sql("SELECT * FROM [dbo].[promotional_tokens_logs] WHERE msisdn = '#{isdn}'")
			# if check_trans.blank?
			# 	# @totalpurchased = @totalpurchased/1000
			# 	# consumed = Token.find_by_sql("select sum(volume)/(1024*1024) as vol from detailed_consumption_new where msisdn = '#{isdn}' and cast(insert_date as date) BETWEEN '#{@purchaseddate}' AND '#{Date.today}'")
			# 	# consumed.each do |cons|
			# 	# 	@consumedd = cons.vol.to_i
			# 	# end
			# 	@difference = (@totalpurchased.to_i-(@consumedd.to_i + @token/1000)).to_i
			# 	# if @difference > 10
			# 	# 	@refund = true
			# 	# 	@numm = isdn
			# 	# else
			# 	# 	@refund = false
			# 	# end
			# end
			# if !@account_history.blank?
			# 	@purchasedd = "true"
			# # end
			# end
		#end
	end

	def rings
		@tones = Tone.all
		render :layout => "subdetails"
	end


	def vas_actions
		if params[:check_vas]
			session[:consumption] = nil
		end

			@tones = Tone.all.order('Ring_Name')
			msisdn = session[:msisdn]
			num220 = "220" + session[:msisdn]

		if params[:activate_crbt]

			if(session[:report_role] != "telemarketing")
				CrbtCharge.new(:msisdn => msisdn, :rbt_type => 1, :status => 0, :timestamp => Time.now).save
			end
			Subqueue.new(:MSISDN => "220" + msisdn, :Tone_ID => params[:toneid], :Status => 0, :TimeStamp => Time.now).save
			sleep 25
			Custcarelog.new(:msisdn	=> msisdn, :username => session[:username], :full_name => session[:fullname], :department => session[:department], :role => session[:userrole], :transaction_type => "CRBT", :action_performed => "Activate", :description =>"Activate CRBT").save
			UserLog.new(:user => session[:fullname], :transaction_type => "CRBT", :description => "Activate CRBT", :msisdn => msisdn, :ip_address =>request.remote_ip, :username => session[:username], :created_at => Time.now).save
			redirect_to customercare_vas_path(:msisdn => msisdn) and return

		elsif params[:deactivate_crbt]

			Unsubqueue.new(:msisdn => "220"+ msisdn, :Status => 0, :user_flag => 2, :TimeStamp => Time.now).save
			sleep 10
			UserLog.new(:user => session[:fullname], :transaction_type => "CRBT", :description => "Deactivate CRBT", :msisdn => msisdn, :ip_address =>request.remote_ip, :username => session[:username], :created_at => Time.now).save
			Custcarelog.new(:msisdn	=> msisdn, :username => session[:username], :full_name => session[:fullname], :department => session[:department], :role => session[:userrole], :transaction_type => "CRBT", :action_performed => "Deactivate", :description =>"Deactivate CRBT").save
			redirect_to customercare_vas_path(:msisdn => msisdn) and return


		elsif params[:activate_jazeera]

			if session[:postpaid] == 'Prepaid'
				if session[:credit_balance] > -6.5
					Jazeera.new(:msisdn => session[:msisdn], :reg_date => Time.now, :end_date => 31.days.from_now, :num_type => session[:postpaid]).save
					Jazeeralog.new(:msisdn => session[:msisdn], :action => "sub", :service_origin => "AUP", :type => session[:postpaid], :date => Time.now).save
					UserLog.new(:user => session[:fullname], :transaction_type => "Jazeera", :description => "Activate Jazeera", :msisdn => msisdn, :ip_address =>request.remote_ip, :username => session[:username], :created_at => Time.now).save
					Custcarelog.new(:msisdn	=> msisdn, :username => session[:username], :full_name => session[:fullname], :department => session[:department], :role => session[:userrole], :transaction_type => "Jazeera", :action_performed => "Activate", :description =>"Activate Jazeera").save
					charge = Linkedserver.find_by_sql("EXEC CDN...AddCredit '#{session[:msisdn]}','Jazeera_Sub_AUP', -1.5")
				else
					flash[:low_credit] = 'Not enough credit to activate Jazeera'
				end
			else
				Jazeera.new(:msisdn => session[:msisdn], :reg_date => Time.now, :end_date => 31.days.from_now, :num_type => session[:postpaid]).save
				Jazeeralog.new(:msisdn => session[:msisdn], :action => "sub", :service_origin => "AUP", :type => session[:postpaid], :date => Time.now).save
				UserLog.new(:user => session[:fullname], :transaction_type => "Jazeera", :description => "Activate Jazeera", :msisdn => msisdn, :ip_address =>request.remote_ip, :username => session[:username], :created_at => Time.now).save
				Custcarelog.new(:msisdn	=> msisdn, :username => session[:username], :full_name => session[:fullname], :department => session[:department], :role => session[:userrole], :transaction_type => "Jazeera", :action_performed => "Activate", :description =>"Activate Jazeera").save
			end
				redirect_to customercare_vas_path(:msisdn => msisdn) and return

		elsif params[:deactivate_jazeera]
			Jazeera.delete_all(:msisdn => msisdn)
			Jazeeralog.new(:msisdn => session[:msisdn], :action => "unsub", :service_origin => "AUP", :type => session[:postpaid], :date => Time.now).save
			UserLog.new(:user => session[:fullname], :transaction_type => "CRBT", :description => "Dectivate CRBT", :msisdn => msisdn, :ip_address =>request.remote_ip, :username => session[:username], :created_at => Time.now).save
			Custcarelog.new(:msisdn	=> msisdn, :username => session[:username], :full_name => session[:fullname], :department => session[:department], :role => session[:userrole], :transaction_type => "Jazeera", :action_performed => "Deactivate", :description =>"Deactivate Jazeera").save
			redirect_to customercare_vas_path(:msisdn => msisdn) and return

		elsif params[:activate_sport]

			if session[:postpaid] == 'Prepaid'
				if session[:credit_balance] > -6.5
					Sport.new(:msisdn => session[:msisdn], :reg_date => Time.now, :end_date => 31.days.from_now, :num_type => session[:postpaid]).save
					UserLog.new(:user => session[:fullname], :transaction_type => "Sport", :description => "Activate Sport Service", :msisdn => msisdn, :ip_address =>request.remote_ip, :username => session[:username], :created_at => Time.now).save
					Custcarelog.new(:msisdn	=> msisdn, :username => session[:username], :full_name => session[:fullname], :department => session[:department], :role => session[:userrole], :transaction_type => "Sport Service", :action_performed => "Activate", :description =>"Activate Sport Service").save
					charge = Linkedserver.find_by_sql("EXEC CDN...AddCredit '#{session[:msisdn]}','Sport_Sub_AUP', -1.5")
				else
					flash[:low_credit] = 'Not enough credit to activate Sport'
				end
			else
				Sport.new(:msisdn => session[:msisdn], :reg_date => Time.now, :end_date => 31.days.from_now, :num_type => session[:postpaid]).save
				UserLog.new(:user => session[:fullname], :transaction_type => "Sport", :description => "Activate Sport Service", :msisdn => msisdn, :ip_address =>request.remote_ip, :username => session[:username], :created_at => Time.now).save
				Custcarelog.new(:msisdn	=> msisdn, :username => session[:username], :full_name => session[:fullname], :department => session[:department], :role => session[:userrole], :transaction_type => "Sport Service", :action_performed => "Activate", :description =>"Activate Sport Service").save
			end
				redirect_to customercare_vas_path(:msisdn => msisdn) and return

		elsif params[:deactivate_sport]

			Sport.delete_all(:msisdn => msisdn)
			UserLog.new(:user => session[:fullname], :transaction_type => "Sport", :description => "Deactivate Sport Service", :msisdn => msisdn, :ip_address =>request.remote_ip, :username => session[:username], :created_at => Time.now).save
			Custcarelog.new(:msisdn	=> msisdn, :username => session[:username], :full_name => session[:fullname], :department => session[:department], :role => session[:userrole], :transaction_type => "Sport Service", :action_performed => "Deactivate", :description =>"Deactivate Sport Service").save
			redirect_to customercare_vas_path(:msisdn => msisdn) and return

		elsif params[:activate_prayertime]
			if session[:postpaid] == 'Prepaid'
				if session[:credit_balance] > -6.5
					Prayer.new(:msisdn => session[:msisdn], :reg_date => Time.now, :end_date => 31.days.from_now, :num_type => session[:postpaid]).save
					UserLog.new(:user => session[:fullname], :transaction_type => "prayertime", :description => "Activate Prayer Time", :msisdn => msisdn, :ip_address =>request.remote_ip, :username => session[:username], :created_at => Time.now).save
					Custcarelog.new(:msisdn	=> msisdn, :username => session[:username], :full_name => session[:fullname], :department => session[:department], :role => session[:userrole], :transaction_type => "Prayer Time", :action_performed => "Activate", :description =>"Activate Prayer Time").save
					charge = Linkedserver.find_by_sql("EXEC CDN...AddCredit '#{session[:msisdn]}','Prayer_Sub_AUP', -1")
				else
					flash[:low_credit] = 'Not enough credit to activate Prayer Time'
				end
			else
				Prayer.new(:msisdn => session[:msisdn], :reg_date => Time.now, :end_date => 31.days.from_now, :num_type => session[:postpaid]).save
				UserLog.new(:user => session[:fullname], :transaction_type => "prayertime", :description => "Activate Prayer Time", :msisdn => msisdn, :ip_address =>request.remote_ip, :username => session[:username], :created_at => Time.now).save
				Custcarelog.new(:msisdn	=> msisdn, :username => session[:username], :full_name => session[:fullname], :department => session[:department], :role => session[:userrole], :transaction_type => "Prayer Time", :action_performed => "Activate", :description =>"Activate Prayer Time").save
			end
				redirect_to customercare_vas_path(:msisdn => msisdn) and return

		elsif params[:deactivate_prayertime]

			Prayer.delete_all(:msisdn => msisdn)
			UserLog.new(:user => session[:fullname], :transaction_type => "prayertime", :description => "Deactivate Prayer Time", :msisdn => msisdn, :ip_address =>request.remote_ip, :username => session[:username], :created_at => Time.now).save
			Custcarelog.new(:msisdn	=> msisdn, :username => session[:username], :full_name => session[:fullname], :department => session[:department], :role => session[:userrole], :transaction_type => "Prayer Time", :action_performed => "Deactivate", :description =>"Deactivate Prayer Time").save
			redirect_to customercare_vas_path(:msisdn => msisdn) and return

		#elsif params[:activate_names]

		#	ifpostpaid = Postpaid.where(msisdn: "220"+msisdn)
		#	if ifpostpaid.blank?
		#		postpaid = "Prepaid"
		#	else
		#		postpaid = "Postpaid"
		#	end
		#	Allah.new(:msisdn => session[:msisdn], :reg_date => Time.now, :end_date => 31.days.from_now, :num_type => postpaid, :sent_msg =>0).save
		#	UserLog.new(:user => session[:fullname], :transaction_type => "99 Names of Allah", :description => "Activate 99 Names of Allah", :msisdn => msisdn, :ip_address =>request.remote_ip, :username => session[:username], :created_at => Time.now).save
		#	Custcarelog.new(:msisdn	=> msisdn, :username => session[:username], :full_name => session[:fullname], :department => session[:department], :role => session[:userrole], :transaction_type => "99 Names of Allah", :action_performed => "Activate", :description =>"Activate 99 Names of Allah").save
		#	redirect_to customercare_vas_path(:msisdn => msisdn) and return

		#elsif params[:deactivate_names]

		#	Allah.delete_all(:msisdn => msisdn)
		#	UserLog.new(:user => session[:fullname], :transaction_type => "99 Names of Allah", :description => "Deactivate 99 Names of Allah", :msisdn => msisdn, :ip_address =>request.remote_ip, :username => session[:username], :created_at => Time.now).save
		#	Custcarelog.new(:msisdn	=> msisdn, :username => session[:username], :full_name => session[:fullname], :department => session[:department], :role => session[:userrole], :transaction_type => "99 Names of Allah", :action_performed => "Deactivate", :description =>"Deactivate 99 Names of Allah").save
		#	redirect_to customercare_vas_path(:msisdn => msisdn) and return

		elsif params[:activate_boy]

			if session[:postpaid] == 'Prepaid'
				if session[:credit_balance] > -6.5
					Boy.new(:msisdn => session[:msisdn], :reg_date => Time.now, :end_date => 31.days.from_now, :num_type => session[:postpaid]).save
					UserLog.new(:user => session[:fullname], :transaction_type => "Boy Service", :description => "Activate Boy Service", :msisdn => msisdn, :ip_address =>request.remote_ip, :username => session[:username], :created_at => Time.now).save
					Custcarelog.new(:msisdn	=> msisdn, :username => session[:username], :full_name => session[:fullname], :department => session[:department], :role => session[:userrole], :transaction_type => "Boy Service", :action_performed => "Activate", :description =>"Activate Boy Service").save
					charge = Linkedserver.find_by_sql("EXEC CDN...AddCredit '#{session[:msisdn]}','Boy_Sub_AUP', -1")
				else
					flash[:low_credit] = 'Not enough credit to activate Boy'
				end
			else
				Boy.new(:msisdn => session[:msisdn], :reg_date => Time.now, :end_date => 31.days.from_now, :num_type => session[:postpaid]).save
				UserLog.new(:user => session[:fullname], :transaction_type => "Boy Service", :description => "Activate Boy Service", :msisdn => msisdn, :ip_address =>request.remote_ip, :username => session[:username], :created_at => Time.now).save
				Custcarelog.new(:msisdn	=> msisdn, :username => session[:username], :full_name => session[:fullname], :department => session[:department], :role => session[:userrole], :transaction_type => "Boy Service", :action_performed => "Activate", :description =>"Activate Boy Service").save
			end
			redirect_to customercare_vas_path(:msisdn => msisdn) and return

		elsif params[:deactivate_boy]

			Boy.delete_all(:msisdn => msisdn)
			UserLog.new(:user => session[:fullname], :transaction_type => "Boy Service", :description => "Deactivate Boy Service", :msisdn => msisdn, :ip_address =>request.remote_ip, :username => session[:username], :created_at => Time.now).save
			Custcarelog.new(:msisdn	=> msisdn, :username => session[:username], :full_name => session[:fullname], :department => session[:department], :role => session[:userrole], :transaction_type => "Boy Service", :action_performed => "Deactivate", :description =>"Deactivate Boy Service").save
			redirect_to customercare_vas_path(:msisdn => msisdn) and return

		elsif params[:activate_girl]
			if session[:postpaid] == 'Prepaid'
				if session[:credit_balance] > -6.5
					Girl.new(:msisdn => session[:msisdn], :reg_date => Time.now, :end_date => 31.days.from_now, :num_type => session[:postpaid]).save
					UserLog.new(:user => session[:fullname], :transaction_type => "Girl Service", :description => "Activate Girl Service", :msisdn => msisdn, :ip_address =>request.remote_ip, :username => session[:username], :created_at => Time.now).save
					Custcarelog.new(:msisdn	=> msisdn, :username => session[:username], :full_name => session[:fullname], :department => session[:department], :role => session[:userrole], :transaction_type => "Girl Service", :action_performed => "Activate", :description =>"Activate Girl Service").save
					charge = Linkedserver.find_by_sql("EXEC CDN...AddCredit '#{session[:msisdn]}','Girl_Sub_AUP', -1")
				else
					flash[:low_credit] = 'Not enough credit to activate Girl'
				end
			else
				Girl.new(:msisdn => session[:msisdn], :reg_date => Time.now, :end_date => 31.days.from_now, :num_type => session[:postpaid]).save
				UserLog.new(:user => session[:fullname], :transaction_type => "Girl Service", :description => "Activate Girl Service", :msisdn => msisdn, :ip_address =>request.remote_ip, :username => session[:username], :created_at => Time.now).save
				Custcarelog.new(:msisdn	=> msisdn, :username => session[:username], :full_name => session[:fullname], :department => session[:department], :role => session[:userrole], :transaction_type => "Girl Service", :action_performed => "Activate", :description =>"Activate Girl Service").save
			end
			redirect_to customercare_vas_path(:msisdn => msisdn) and return

		elsif params[:deactivate_girl]

			Girl.delete_all(:msisdn => msisdn)
			UserLog.new(:user => session[:fullname], :transaction_type => "Girl Service", :description => "Deactivate Girl Service", :msisdn => msisdn, :ip_address =>request.remote_ip, :username => session[:username], :created_at => Time.now).save
			Custcarelog.new(:msisdn	=> msisdn, :username => session[:username], :full_name => session[:fullname], :department => session[:department], :role => session[:userrole], :transaction_type => "Girl Service", :action_performed => "Deactivate", :description =>"Deactivate Girl Service").save
			redirect_to customercare_vas_path(:msisdn => msisdn) and return


		elsif params[:activate_horoscope]

			if session[:postpaid] == 'Prepaid'
				if session[:credit_balance] > -6.5
					enddate = 31.days.from_now.to_date
					Horoscope.new(:msisdn => msisdn, :reg_date => Date.today, :end_date => enddate, :num_type => session[:postpaid], :horo_type => params[:horotype]).save
					UserLog.new(:user => session[:fullname], :transaction_type => "Horoscope", :description => "Activate Horoscope", :msisdn => msisdn, :ip_address =>request.remote_ip, :username => session[:username], :created_at => Time.now).save
					Custcarelog.new(:msisdn	=> msisdn, :username => session[:username], :full_name => session[:fullname], :department => session[:department], :role => session[:userrole], :transaction_type => "Horoscope", :action_performed => "Activate", :description =>"Activate Horoscope").save
					charge = Linkedserver.find_by_sql("EXEC CDN...AddCredit '#{session[:msisdn]}','Horoscope_Sub_AUP', -1")
				else
					flash[:low_credit] = 'Not enough credit to activate Horoscope'
				end
			else
				enddate = 31.days.from_now.to_date
				Horoscope.new(:msisdn => msisdn, :reg_date => Date.today, :end_date => enddate, :num_type => session[:postpaid], :horo_type => params[:horotype]).save
				UserLog.new(:user => session[:fullname], :transaction_type => "Horoscope", :description => "Activate Horoscope", :msisdn => msisdn, :ip_address =>request.remote_ip, :username => session[:username], :created_at => Time.now).save
				Custcarelog.new(:msisdn	=> msisdn, :username => session[:username], :full_name => session[:fullname], :department => session[:department], :role => session[:userrole], :transaction_type => "Horoscope", :action_performed => "Activate", :description =>"Activate Horoscope").save
			end
			redirect_to customercare_vas_path(:msisdn => msisdn) and return

		elsif params[:deactivate_horoscope]

			Horoscope.delete_all(:msisdn => msisdn)
			UserLog.new(:user => session[:fullname], :transaction_type => "Horoscope", :description => "Deactivate Horoscope", :msisdn => msisdn, :ip_address =>request.remote_ip, :username => session[:username], :created_at => Time.now).save
			Custcarelog.new(:msisdn	=> msisdn, :username => session[:username], :full_name => session[:fullname], :department => session[:department], :role => session[:userrole], :transaction_type => "Horoscope", :action_performed => "Deactivate", :description =>"Deactivate Horoscope").save
			redirect_to customercare_vas_path(:msisdn => msisdn) and return

		elsif params[:activate_kolareh]

			Linkedserver.find_by_sql(["EXEC CDN...sp_esme_loyalty_optin '#{msisdn}'"])
			UserLog.new(:user => session[:fullname], :transaction_type => "Kolareh", :description => "Activate Kolareh", :msisdn => msisdn, :ip_address =>request.remote_ip, :username => session[:username], :created_at => Time.now).save
			Custcarelog.new(:msisdn	=> msisdn, :username => session[:username], :full_name => session[:fullname], :department => session[:department], :role => session[:userrole], :transaction_type => "Kolareh", :action_performed => "Activate", :description =>"Activate Kolareh").save
			redirect_to customercare_vas_path(:msisdn => msisdn) and return

		elsif params[:deactivate_kolareh]

			Linkedserver.find_by_sql(["EXEC CDN...sp_esme_loyalty_optout '#{msisdn}'"])
			UserLog.new(:user => session[:fullname], :transaction_type => "Kolareh", :description => "Deactivate Kolareh", :msisdn => msisdn, :ip_address =>request.remote_ip, :username => session[:username], :created_at => Time.now).save
			Custcarelog.new(:msisdn	=> msisdn, :username => session[:username], :full_name => session[:fullname], :department => session[:department], :role => session[:userrole], :transaction_type => "Kolareh", :action_performed => "Deactivate", :description =>"Deactivate Kolareh").save
			redirect_to customercare_vas_path(:msisdn => msisdn) and return

		elsif params[:fix3g]
			number ='220'+msisdn
			#Token.connection.execute("EXEC fix_3G_service_web '#{msisdn}','web app'")
			check205 = Fix3g.where(msisdn: number).first
			if !check205.blank?
				check205.update_attributes(:status => 3)
			end
			UserLog.new(:user => session[:fullname], :transaction_type => "3G Fix", :description => "3G Fix web App", :msisdn => msisdn, :ip_address =>request.remote_ip, :username => session[:username], :created_at => Time.now).save
			Custcarelog.new(:msisdn	=> msisdn, :username => session[:username], :full_name => session[:fullname], :department => session[:department], :role => session[:userrole], :transaction_type => "3G", :action_performed => "Activate", :description =>"Fix 3G").save
			redirect_to customercare_vas_path(:msisdn => msisdn) and return

		elsif params[:consumption]

			date1 = params[:y1]+params[:m1]+params[:d1]
			date2 = params[:y2]+params[:m2]+params[:d2]

			consumed = Token.find_by_sql("select sum(volume)/(1024*1024) as vol from detailed_consumption_new where msisdn = '#{num220}' and cast(insert_date as date) BETWEEN '#{date1}' AND '#{date2}'")
			#session[:consumption] = consumed.volume #/1024/1024
			consumed.each do |cons|
				session[:consumption] = cons.vol.to_i
			end
			UserLog.new(:user => session[:fullname], :transaction_type => "3G Fix", :description => "3G Consumption", :msisdn => msisdn, :ip_address =>request.remote_ip, :username => session[:username], :created_at => Time.now).save
			Custcarelog.new(:msisdn	=> msisdn, :username => session[:username], :full_name => session[:fullname], :department => session[:department], :role => session[:userrole], :transaction_type => "3G", :action_performed => "Comsumption", :description =>"Check 3G Consumption").save
			redirect_to customercare_vas_path(:msisdn => msisdn) and return


		elsif params[:activate_iclip]

			stdate = Date.today.strftime("%d-%m-%Y").to_s
			startdate = stdate[0..1] + stdate[3..4] + stdate[6..9]
			expdate = (31.days.from_now).strftime("%d-%m-%Y").to_s
			enddate = expdate[0..1] + expdate[3..4] + expdate[6..9]

			exists = Linkedserver.find_by_sql("select * from openquery(iclip,'select * from dbo.ICLIP where PHONENUMBER = ''#{msisdn}''')")
			if exists.blank?
				Linkedserver.find_by_sql("INSERT OpenQuery(iclip, 'SELECT NAME,PHONENUMBER,STARTDATE,ENDDATE FROM dbo.ICLIP') VALUES ('#{session[:postpaid]}','#{msisdn}','#{startdate}','#{enddate}')")
			else
				Linkedserver.find_by_sql("UPDATE OPENQUERY(iclip, 'SELECT STARTDATE,ENDDATE FROM dbo.ICLIP WHERE PHONENUMBER = ''#{msisdn}''') SET STARTDATE = '#{startdate}', ENDDATE = '#{enddate}'")
			end
			if(session[:postpaid] == "Prepaid")
				Linkedserver.find_by_sql(["EXEC AddCredit '#{msisdn}','Iclip', -5"])
			end
			UserLog.new(:user => session[:fullname], :transaction_type => "ICLIP", :description => "Activate ICLIP", :msisdn => msisdn, :ip_address =>request.remote_ip, :username => session[:username], :created_at => Time.now).save
			Custcarelog.new(:msisdn => msisdn, :username => session[:username], :full_name => session[:fullname], :department => session[:department], :role => session[:userrole], :transaction_type => "ICLIP", :action_performed => "Activate", :description =>"Activate ICLIP").save
			redirect_to customercare_vas_path(:msisdn => msisdn) and return

		elsif params[:deactivate_iclip]

			Linkedserver.find_by_sql("DELETE OPENQUERY (iclip, 'SELECT * FROM dbo.ICLIP WHERE PHONENUMBER = ''#{msisdn}''')")
			UserLog.new(:user => session[:fullname], :transaction_type => "ICLIP", :description => "Deactivate ICLIP", :msisdn => msisdn, :ip_address =>request.remote_ip, :username => session[:username], :created_at => Time.now).save
			Custcarelog.new(:msisdn => msisdn, :username => session[:username], :full_name => session[:fullname], :department => session[:department], :role => session[:userrole], :transaction_type => "ICLIP", :action_performed => "Deactivate", :description =>"Deactivate ICLIP").save
			redirect_to customercare_vas_path(:msisdn => msisdn) and return

		elsif params[:activate_validity]
			client = Savon.client(wsdl: "http://192.168.0.232:8080/axis2/services/WebService?wsdl")
		  	message = { :operatorName.to_s => 'AUP', :MSISDN.to_s => msisdn.to_s }
		  	response = client.call(:get_account_details, message: message).xml
		  	Nokogiri::HTML(response).root.children.each do |node|
				@balance = node.at_css('balance').content.to_i
				@cosvalid_status = node.at_css('cos')
			end

			if(session[:postpaid] == "Prepaid")
				if @balance >= 10
					exists = ValRoam.where(msisdn: msisdn)
					exp_date = 1.year.from_now
					expiry_date = exp_date.to_date
					Release8.find_by_sql(["EXEC modifyCOS '#{msisdn}','AUP','Africell validity'"])
					if exists.blank?
						ValRoam.find_by_sql("Insert into val_roam values ('#{msisdn}','#{expiry_date}',4,40)")
					else
						ValRoam.find_by_sql("UPDATE val_roam set expiry_date = '#{expiry_date}', update_type = 4, cos_num = 40 where msisdn = '#{msisdn}'")
					end
					#Linkedserver.find_by_sql(["EXEC AddCredit '#{msisdn}','Iclip', -10"])
					#Release8.find_by_sql(["EXEC AddCredit '#{msisdn}',-10,'AUP Validity'"])
					UserLog.new(:user => session[:fullname], :transaction_type => "Validity", :description => "Activate Validity", :msisdn => msisdn, :ip_address =>request.remote_ip, :username => session[:username], :created_at => Time.now).save
					Custcarelog.new(:msisdn => msisdn, :username => session[:username], :full_name => session[:fullname], :department => session[:department], :role => session[:userrole], :transaction_type => "Validity", :action_performed => "Activate", :description =>"Activate Validity").save
				else
					flash[:low_credit] = 'Not enough credit to activate Validity'
				end

			end
				redirect_to customercare_vas_path(:msisdn => msisdn) and return

		elsif params[:deactivate_validity]

			ValRoam.find_by_sql("delete from val_roam where msisdn = '#{msisdn}'")
			Release8.find_by_sql(["EXEC modifyCOS '#{msisdn}','AUP','Africell'"])
			UserLog.new(:user => session[:fullname], :transaction_type => "Validity", :description => "Deactivate Validity", :msisdn => msisdn, :ip_address =>request.remote_ip, :username => session[:username], :created_at => Time.now).save
			Custcarelog.new(:msisdn => msisdn, :username => session[:username], :full_name => session[:fullname], :department => session[:department], :role => session[:userrole], :transaction_type => "Validity", :action_performed => "Deactivate", :description =>"Deactivate Validity").save
			redirect_to customercare_vas_path(:msisdn => msisdn) and return

		elsif params[:activate_roaming]
			if(session[:postpaid] == "Prepaid")
				Release8.find_by_sql(["EXEC modifyCOS '#{msisdn}','AUP','Roaming'"])
				roamoutput = Hlr.new.execute("BAROAM","192.167.0.12","BSUWEB","BSU@123",msisdn,'NOBAR',nil,nil,nil,nil,nil,nil,nil,nil)
				exists = ValRoam.where(msisdn: msisdn)
				exp_date = 1.year.from_now
				expiry_date = exp_date.to_date
				if exists.blank?
					ValRoam.find_by_sql("Insert into val_roam values ('#{msisdn}','#{expiry_date}',3,29)")
				else
					ValRoam.find_by_sql("UPDATE val_roam set expiry_date = '#{expiry_date}', update_type = 3, cos_num = 29 where msisdn = '#{msisdn}'")
				end
			end
			UserLog.new(:user => session[:fullname], :transaction_type => "Roaming", :description => "Activate Roaming", :msisdn => msisdn, :ip_address =>request.remote_ip, :username => session[:username], :created_at => Time.now).save
			Custcarelog.new(:msisdn => msisdn, :username => session[:username], :full_name => session[:fullname], :department => session[:department], :role => session[:userrole], :transaction_type => "Roaming", :action_performed => "Activate", :description =>"Activate Roaming").save
			redirect_to customercare_vas_path(:msisdn => msisdn) and return

		elsif params[:deactivate_roaming]

			ValRoam.find_by_sql("delete from val_roam where msisdn = '#{msisdn}'")
			Release8.find_by_sql(["EXEC modifyCOS '#{msisdn}','AUP','Africell'"])
			roamoutput = Hlr.new.execute("BAROAM","192.167.0.12","BSUWEB","BSU@123",msisdn,'BROHPLMN',nil,nil,nil,nil,nil,nil,nil,nil)
			UserLog.new(:user => session[:fullname], :transaction_type => "Roaming", :description => "Deactivate Roaming", :msisdn => msisdn, :ip_address =>request.remote_ip, :username => session[:username], :created_at => Time.now).save
			Custcarelog.new(:msisdn => msisdn, :username => session[:username], :full_name => session[:fullname], :department => session[:department], :role => session[:userrole], :transaction_type => "Roaming", :action_performed => "Deactivate", :description =>"Deactivate Roaming").save
			redirect_to customercare_vas_path(:msisdn => msisdn) and return


		elsif params[:activate_tok]

		  	if msisdn != params[:toknumber]
		  		ffexist = Tok.where(msisdn: msisdn)
		  		if !ffexist.blank?
		  			client = Savon.client(wsdl: "http://192.168.0.232:8080/axis2/services/WebService?wsdl")
					checkcos = { :operatorName.to_s => 'AUP', :MSISDN.to_s => msisdn }
				  	cosresponse = client.call(:get_account_details, message: checkcos).xml
				  	Nokogiri::HTML(cosresponse).root.children.each do |node|
						@cos = node.at_css('cos').content
					end
					case @cos
                     	when 'Africell'
                     		@cos = 'FandF'
                   		when 'Africell validity'
                   			@cos = 'FandF'
                   		when 'Roaming'
                   			@cos = 'FandF'
                   		when 'SchoolSIM'
                   			@cos = 'FandF'
                   		when 'Wolof'
                   			@cos = 'FandFWolof'
                   		when 'Mandinka'
                   			@cos = 'FandFMandinka'
                   		when 'French'
                   			@cos = 'FandFFrench'
                   		when 'AfricellCFBlock'
                   			@cos = 'FandF-CFBlock'
                   		when 'Africell25D'
                   			@cos = 'FandFAfricell25D'
                   	end
                   	Release8.find_by_sql(["EXEC modifyCOS '#{msisdn}','AUP','#{@cos}'"])
                   	sleep 1
					message = { :operatorName.to_s => 'AUP', :MSISDN.to_s => msisdn, :FFNumber.to_s => params[:toknumber], :FFType.to_s => 'Type 1' }
					response = client.call(:add_ff_number, message: message).xml
				else
					flash[:tokerror] = 'Number has to send SMS'
					redirect_to customercare_vas_path(:msisdn => msisdn) and return
				end
				#getcos = Tok.find_by_sql("select * from openquery(CDN,'SELECT cos_num FROM dbo.db_subscriber_tbl WHERE subscriber_id = ''#{msisdn}''')")
				#getcos.each do |cosnum|
				#	@cosnumber = cosnum.cos_num
				#end
				#activate_tok = Tok.connection.execute("EXEC AddTOKNumber '#{msisdn}','#{params[:toknumber]}'")
				#change_cos =  TokCos.connection.execute("EXEC TOK_COS_UPD '#{msisdn}','#{@cosnumber}'")
				UserLog.new(:user => session[:fullname], :transaction_type => "TOK", :description => "Activate TOK", :msisdn => msisdn, :ip_address =>request.remote_ip, :username => session[:username], :created_at => Time.now).save
				Custcarelog.new(:msisdn	=> msisdn, :username => session[:username], :full_name => session[:fullname], :department => session[:department], :role => session[:userrole], :transaction_type => "TOK", :action_performed => "Activate", :description =>"Activate TOK").save
				redirect_to customercare_vas_path(:msisdn => msisdn) and return
			else
				flash[:tokerror] = 'Cannot Activate The Same Number'
				redirect_to customercare_vas_path(:msisdn => msisdn) and return
			end
		end

			respond_to do | format |
		    	format.html
		        format.js #{render :layout => false}
		    end

	end

	def horoscope
		respond_to do | format |
	    	format.html
	        format.js
		end
	end

	def gprs
		respond_to do | format |
	    	format.html
	        format.js
		end
	end

	def tok
		respond_to do | format |
	    	format.html
	        format.js
		end
	end

	def over_scratched

		@serialnumber = params[:serial]

		session[:serial] = params[:serial]
		session[:msisdn] = params[:msisdn]
		name = params[:f_name] +" "+params[:l_name]
		session[:custname] = name

		@agent = UserLog.where('description =? and serial =?', "Invalid Scratch cards Recharge", session[:serial])

		@results = Linkedserver.find_by_sql("select * from openquery(CDN,'select * from db_voucher_tbl where serial_num =''#{params[:serial]}''')")
		Custcarelog.new(:msisdn	=> params[:msisdn], :username => session[:username], :full_name => session[:fullname], :department => session[:department], :role => session[:userrole], :transaction_type => "Over Scratched", :action_performed => "Serial Number Query "+ params[:serial], :description =>"Over Scratched Serial Number Queried").save
		CustcareRegistration.new(:msisdn => params[:msisdn], :first_name => params[:f_name], :last_name => params[:l_name], :id_type => params[:id_type], :id_number => params[:id_number], :custcare_agent => session[:fullname]).save
		#log = Logs.new(:user => @session['user'].name, :transaction_type => "Invalid Cards", :name =>session[:name], :description => "Serial Number Queried", :msisdn => session[:msisdn], :ip_address =>@client_ip, :created_at => Time.now, :username => @session['user'].login).save
		UserLog.new(:user => session[:fullname], :transaction_type => "Invalid Cards", :description => "Serial Number Queried", :msisdn => params[:msisdn], :name => name, :serial =>params[:serial], :ip_address =>request.remote_ip, :username => session[:username], :created_at => Time.now).save
		session[:resul] = @results

		if @results.blank?

			@getmsisdn = Linkedserver.find_by_sql("select * from openquery(CDN,'select * from db_voucher_used_tbl where serial_num =''#{params[:serial]}''')")

			if @getmsisdn.blank?

				seriesnum1 = params[:serial].to_s[0..3]
				serialnum1 = params[:serial].to_s[4..11]

				seriesnum = seriesnum1.to_i
				serialnum = serialnum1.to_i

				@queryoracle = Linkedserver.find_by_sql("select * from openquery(VCHR,'select * from voucher where seriesno=''#{seriesnum}'' and serialno=''#{serialnum}''')")

					if @queryoracle.blank?

						#log = Logs.new(:user => @session['user'].name, :transaction_type => "Invalid Cards", :name =>session[:name], :description => "Wrong serial Number Inserted", :msisdn => session[:msisdn], :ip_address =>@client_ip, :created_at => Time.now, :username => @session['user'].login).save
						UserLog.new(:user => session[:fullname], :transaction_type => "Invalid Cards", :description => "Wrong Serial Number Inserted", :msisdn => params[:msisdn], :name => name, :serial =>params[:serial], :ip_address =>request.remote_ip, :username => session[:username], :created_at => Time.now).save
						flash[:invalid] = 'WRONG SERIAL NUMBER'
						redirect_to customercare_invalid_select_path # and return
					end
			end
		else
			redirect_to customercare_invalid_path #(:msisdn => msisdn) and return
		end
	end

	def invalid

		session[:resul].each do |result|

			@hidden_number = result.voucher_num

			hid0 = result.voucher_num.to_s[0..0]
			hid1 = result.voucher_num.to_s[1..1]
			hid2 = result.voucher_num.to_s[2..2]
			hid3 = result.voucher_num.to_s[3..3]
			hid4 = result.voucher_num.to_s[4..4]
			hid5 = result.voucher_num.to_s[5..5]
			hid6 = result.voucher_num.to_s[6..6]
			hid7 = result.voucher_num.to_s[7..7]
			hid8 = result.voucher_num.to_s[8..8]
			hid9 = result.voucher_num.to_s[9..9]
			hid10 = result.voucher_num.to_s[10..10]
			hid11 = result.voucher_num.to_s[11..11]
			hid12 = result.voucher_num.to_s[12..12]
			hid13 = result.voucher_num.to_s[13..13]
			hid14 = result.voucher_num.to_s[14..14]
			hid15 = result.voucher_num.to_s[15..15]




			if (hid0 == params[:box1])
				@compare1 = 1
			else
				@compare1 = 0
			end
			if (hid1 == params[:box2])
				@compare2 = 1
			else
				@compare2 = 0
			end
			if (hid2 == params[:box3])
				@compare3 = 1
			else
				@compare3 = 0
			end
			if (hid3 == params[:box4])
				@compare4 = 1
			else
				@compare4 = 0
			end
			if (hid4 == params[:box5])
				@compare5 = 1
			else
				@compare5 = 0
			end
			if (hid5 == params[:box6])
				@compare6 = 1
			else
				@compare6 = 0
			end
			if (hid6 == params[:box7])
				@compare7 = 1
			else
				@compare7 = 0
			end
			if (hid7 == params[:box8])
				@compare8 = 1
			else
				@compare8 = 0
			end
			if (hid8 == params[:box9])
				@compare9 = 1
			else
				@compare9 = 0
			end
			if (hid9 == params[:box10])
				@compare10 = 1
			else
				@compare10 = 0
			end
			if (hid10 == params[:box11])
				@compare11 = 1
			else
				@compare11 = 0
			end
			if (hid11 == params[:box12])
				@compare12 = 1
			else
				@compare12 = 0
			end
			if (hid12 == params[:box13])
				@compare13 = 1
			else
				@compare13 = 0
			end
			if (hid13 == params[:box14])
				@compare14 = 1
			else
				@compare14 = 0
			end
			if (hid14 == params[:box15])
				@compare15 = 1
			else
				@compare15 = 0
			end
			if (hid15 == params[:box16])
				@compare16 = 1
			else
				@compare16 = 0
			end

		end

		total = @compare1.to_i + @compare2.to_i + @compare3.to_i + @compare4.to_i + @compare5.to_i + @compare6.to_i + @compare7.to_i + @compare8.to_i + @compare9.to_i + @compare10.to_i + @compare11.to_i + @compare12.to_i + @compare13.to_i + @compare14.to_i + @compare15.to_i + @compare16.to_i



		if params[:compare_button]

			if (total >= 6)

				Linkedserver.connection.execute("exec CDN...UseVoucher '#{session[:serial]}','#{session[:msisdn]}','invalid'")

				#log = Logs.new(:user => @session['user'].name, :transaction_type => "Invalid Cards", :name =>session[:name], :description => "Invalid Scratch cards Recharge", :msisdn => session[:msisdn], :ip_address =>@client_ip, :created_at => Time.now, :username => @session['user'].login).save
				UserLog.new(:user => session[:fullname], :transaction_type => "Invalid Cards", :description => "Invalid Scratch Cards Recharge", :msisdn =>session[:msisdn], :name => session[:custname], :serial =>session[:serial], :ip_address =>request.remote_ip, :username => session[:username], :created_at => Time.now).save
				flash[:done] = "RECHARGE SUCCESSFUL"
				redirect_to customercare_invalid_select_path

			else
			#log = Logs.new(:user => @session['user'].name, :transaction_type => "Invalid Cards", :name =>session[:name], :description => "Not enough correct digits", :msisdn => session[:msisdn], :ip_address =>@client_ip, :created_at => Time.now, :username => @session['user'].login).save
			UserLog.new(:user => session[:fullname], :transaction_type => "Invalid Cards", :description => "Not Enough Correct Digists", :msisdn =>session[:msisdn], :name => session[:custname], :serial =>session[:serial], :ip_address =>request.remote_ip, :username => session[:username], :created_at => Time.now).save
			flash[:cannot] = "CANNOT RECHARGE! NOT ENOUGH CORRECT NUMBERS"
			redirect_to customercare_invalid_path

			end
		end
	end

	def new_sheet

		customer_name =params[:name].to_s+" "+params[:l_name].to_s

		Custcarelog.new(:msisdn	=> params[:msisdn], :username => session[:username], :customer_name => customer_name, :full_name => session[:fullname], :department => session[:department], :role => session[:userrole], :transaction_type => params[:transaction_type], :description =>params[:description]).save
		if params[:newsheet]
			CustcareRegistration.new(:msisdn => params[:msisdn], :first_name => params[:name], :last_name => params[:l_name], :id_type => params[:id_type], :id_number => params[:id_number], :custcare_agent => session[:fullname]).save
			redirect_to customercare_vas_path(:msisdn => params[:msisdn]) and return
		elsif params[:new_sheet]
			CustcareRegistration.new(:msisdn => params[:msisdn], :first_name => params[:name], :last_name => params[:l_name], :id_type => params[:id_type], :id_number => params[:id_number], :custcare_agent => session[:fullname]).save
			flash[:message] = "Work Sheet Saved"
			redirect_to customercare_new_work_sheet_path and return
		end

		respond_to do | format |
	    	format.html
	        format.js
		end
	end
end
