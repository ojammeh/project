class EvcController < ApplicationController
protect_from_forgery :except => [:reverse]

	def reverse
		dealer_num = params[:dealer_number]
		recipient = params[:recipient]
		amount1 = params[:amount1].to_f
		amount2 = params[:amount2].to_f
		amount3 = params[:amount3].to_f
		subtosub_sender = 'UTS_'+params[:dealer_number]
		date = params[:year]+params[:month]+params[:day]
		if session[:evc_role] == 2 and(amount1 < 250 or amount2 < 250 or amount3 < 250)
			flash[:success] = "Minimum amount is 250"
			redirect_to evc_evc_select_path
		else
			if params[:reverse_type] == 'dealertosub'
				#EvcLog.find_by_sql("SELECT * FROM [dbo].[evc_reverse_logs] WHERE transid = #{params[:id]} and [date_sent] = '#{datesent}'")
				@check_evc = LivefeedSsr.find_by_sql("SELECT * FROM [dbo].[vw_ssrs] WHERE cardnum ='#{dealer_num}' AND accnum ='#{recipient}' and ssrtype = 97 and cast([time] AS date)='#{date}' AND (amount = #{amount1} OR amount = #{amount2} OR amount = #{amount3}) order by time desc")
				@type = "dealertosub"
			elsif params[:reverse_type] == 'subtosub'
				@check_evc = LivefeedSsr.find_by_sql("SELECT * FROM [dbo].[vw_ssrs] WHERE accnum ='#{recipient}' and opid = '#{subtosub_sender}' and ssrtype = 2 and cast([time] AS date)='#{date}' AND (amount = #{amount1} OR amount = #{amount2} OR amount = #{amount3}) order by time desc")
				@type = "subtosub"
			elsif params[:reverse_type] == 'dealertodealer'
				@check_evc = LivefeedSsr.find_by_sql("SELECT * FROM [dbo].[vw_ssrs] WHERE cardnum ='#{dealer_num}' AND accnum ='#{recipient}' and ssrtype = 92 and cast([time] AS date)='#{date}' AND (amount = #{amount1} OR amount = #{amount2} OR amount = #{amount3}) order by time desc")	
				@type = "dealertodealer"
			end
		end		
	end

#dealer to normal subscriber transfer
	def reverse_transaction
		if session[:evc_role] == 2 or session[:evc_role] == 1
			reversal = LivefeedSsr.find_by_sql("SELECT * FROM [dbo].[vw_ssrs] WHERE transid = #{params[:id]} order by transid asc").first
			datesent = reversal.time.to_date
			reversal_exists = EvcLog.find_by_sql("SELECT * FROM [dbo].[evc_reverse_logs] WHERE transid = #{params[:id]} and [date_sent] = '#{datesent}'")
			if reversal_exists.blank?	
				amount = reversal.amount
				dealer_num = reversal.cardnum
				recipient = reversal.accnum
				client = Savon.client(wsdl: "http://192.168.0.232:8080/axis2/services/WebService?wsdl")
			  	message = { :operatorName.to_s => 'AUP Reversal', :MSISDN.to_s => recipient }
			  	response = client.call(:get_account_details, message: message).xml
			  	Nokogiri::HTML(response).root.children.each do |node|
					@balance = node.at_css('balance').content.to_i
					@free_money = node.at_css('freemoney').content.to_i
				end
				if(amount < 45)
					freemoney = amount * 0.25
				elsif (amount >= 45 and amount < 95)
					freemoney = amount * 0.5
				elsif (amount >= 95 and amount < 125)
					freemoney = amount * 0.75
				elsif (amount >= 125 and amount <= 10000)
					freemoney = amount * 0.8
				end
				if @balance > 0
					if(@balance >= amount.to_i and @free_money >= freemoney.to_i)
						amount_to_remove = amount.to_i * -1
						freemoney_to_remove = freemoney.to_i * -1
						balmessage = { :operatorName.to_s => 'AUP Reversal', :MSISDN.to_s => recipient, :amount=> amount_to_remove, :validityType.to_s => "N", :validity => 0,
						:freeTime => 0, :freeSMS => 0, :freeMoney => freemoney_to_remove, :freeData => 0 }
				  		balresponse = client.call(:set_account_balances, message: balmessage)
				  		#add dealer credit 
				  		Release8.find_by_sql(["EXEC adddealercredit '#{dealer_num}',#{amount},'AUP Reversal'"])
				  		EvcLog.new(:transid => params[:id], :sender => dealer_num, :recipient => recipient, :amount_sent => amount, :amount_reversed =>amount,
				  			:reverse_type => "Dealer to Subscriber", :username => session[:username], :fullname => session[:fullname], :ip => request.remote_ip,
				  			:date_sent => reversal.time.to_date, :date => Time.now).save
				  		flash[:success] = "Success"

				  	elsif(@balance >= amount.to_i and @free_money < freemoney.to_i)
				  		used_freemoney = freemoney.to_i - @free_money
				  		amount_to_reverse = amount.to_i - used_freemoney.to_i
				  		amount_to_remove = amount.to_i * -1
						freemoney_to_remove = @free_money * -1
						balmessage = { :operatorName.to_s => 'AUP Reversal', :MSISDN.to_s => recipient, :amount => amount_to_remove, :validityType.to_s => "N", :validity => 0,
						:freeTime => 0, :freeSMS => 0, :freeMoney => freemoney_to_remove, :freeData => 0 }
				  		balresponse = client.call(:set_account_balances, message: balmessage)
				  		#add dealer credit 
				  		Release8.find_by_sql(["EXEC adddealercredit '#{dealer_num}',#{amount_to_reverse},'AUP Reversal'"])
				  		EvcLog.new(:transid => params[:id], :sender => dealer_num, :recipient => recipient, :amount_sent => amount, :amount_reversed =>amount_to_reverse,
				  			:reverse_type => "Dealer to Subscriber", :username => session[:username], :fullname => session[:fullname], :ip => request.remote_ip,
				  			:date_sent => reversal.time.to_date, :date => Time.now).save
				  		flash[:success] = "Success"
				  		
				  	elsif(@balance < amount.to_i and @free_money >= freemoney.to_i)
				  		amount_to_remove = @balance.to_i * -1
						freemoney_to_remove = freemoney.to_i * -1
						amount_to_reverse = @balance
						balmessage = { :operatorName.to_s => 'AUP Reversal', :MSISDN.to_s => recipient, :amount => amount_to_remove, :validityType.to_s => "N", :validity => 0,
						:freeTime => 0, :freeSMS => 0, :freeMoney => freemoney_to_remove, :freeData=> 0  }
				  		balresponse = client.call(:set_account_balances, message: balmessage)
				  		#add dealer credit 
				  		Release8.find_by_sql(["EXEC adddealercredit '#{dealer_num}',#{amount_to_reverse},'AUP Reversal'"])
				  		EvcLog.new(:transid => params[:id], :sender => dealer_num, :recipient => recipient, :amount_sent => amount, :amount_reversed =>amount_to_reverse,
				  			:reverse_type => "Dealer to Subscriber", :username => session[:username], :fullname => session[:fullname], :ip => request.remote_ip,
				  			:date_sent => reversal.time.to_date, :date => Time.now).save
				  		flash[:success] = "Success"

				  	elsif(@balance < amount.to_i and @free_money < freemoney.to_i)
				  		used_freemoney = freemoney.to_i - @free_money
				  		used_credit = amount.to_i - @balance
				  		amount_to_remove = @balance.to_f * -1
						freemoney_to_remove = @free_money * -1
						amounttoreverse = amount.to_i - (used_freemoney + used_credit)
						if amounttoreverse >= 0
							amount_to_reverse = amounttoreverse
						else
							amount_to_reverse = 0
						end
						balmessage = { :operatorName.to_s => 'AUP Reversal', :MSISDN.to_s => recipient, :amount => amount_to_remove, :validityType.to_s => "N", :validity => 0,
						:freeTime => 0, :freeSMS => 0, :freeMoney => freemoney_to_remove, :freeData => 0  }
				  		balresponse = client.call(:set_account_balances, message: balmessage)
				  		#add dealer credit 
				  		Release8.find_by_sql(["EXEC adddealercredit '#{dealer_num}',#{amount_to_reverse},'AUP Reversal'"])
				  		EvcLog.new(:transid => params[:id], :sender => dealer_num, :recipient => recipient, :amount_sent => amount, :amount_reversed =>amount_to_reverse,
				  			:reverse_type => "Dealer to Subscriber", :username => session[:username], :fullname => session[:fullname], :ip => request.remote_ip,
				  			:date_sent => reversal.time.to_date, :date => Time.now).save
				  		flash[:success] = "Success"
				  	else
				  		flash[:success] = 'Fail'
					end
				end
			else
				flash[:success] = "This Reversal has already been done"
			end
			redirect_to evc_evc_select_path
		end
	end

#Reverse Subscriber to Subscriber Credit
	def reverse_sub
		if session[:evc_role] == 2 or session[:evc_role] == 1
			reversal = LivefeedSsr.find_by_sql("SELECT * FROM [dbo].[vw_ssrs] WHERE transid = #{params[:id]} order by transid asc").first
			datesent = reversal.time.to_date
			reversal_exists = EvcLog.find_by_sql("SELECT * FROM [dbo].[evc_reverse_logs] WHERE transid = #{params[:id]} and [date_sent] = '#{datesent}'")
			if reversal_exists.blank?
				amount = reversal.amount
				sender = reversal.opid[4..10]
				recipient = reversal.accnum
				client = Savon.client(wsdl: "http://192.168.0.232:8080/axis2/services/WebService?wsdl")
			  	message = { :operatorName.to_s => 'AUP Reversal', :MSISDN.to_s => recipient }
			  	response = client.call(:get_account_details, message: message).xml
			  	Nokogiri::HTML(response).root.children.each do |node|
					@balance = node.at_css('balance').content.to_f
				end
				if @balance > 0
					if @balance >= amount
						amount_to_remove = amount.to_f * -1
						amount_to_reverse = amount
						remove_credit = { :operatorName.to_s => 'AUP Reversal', :MSISDN.to_s => recipient, :amount=> amount_to_remove, :validityType.to_s => "N", :validity => 0,
						:freeTime => 0, :freeSMS => 0, :freeMoney => 0, :freeData => 0 }
				  		remove_response = client.call(:set_account_balances, message: remove_credit)
				  		#add credit 
				  		add_credit = { :operatorName.to_s => 'AUP Reversal', :MSISDN.to_s => sender, :amount => amount_to_reverse, :validityType.to_s => "N", :validity => 0,
						:freeTime => 0, :freeSMS => 0, :freeMoney => 0, :freeData => 0 }
				  		add_response = client.call(:set_account_balances, message: add_credit)
				  		EvcLog.new(:transid => params[:id], :sender => sender, :recipient => recipient, :amount_sent => amount, :amount_reversed =>amount_to_reverse,
				  			:reverse_type => "Subscriber to Subscriber", :username => session[:username], :fullname => session[:fullname], :ip => request.remote_ip,
				  			:date_sent => reversal.time.to_date, :date => Time.now).save
				  		flash[:success] = "Success"
				  		
				  	elsif @balance < amount
				  		amount_to_remove = @balance.to_f * -1
						amount_to_reverse = @balance
						remove_credit = { :operatorName.to_s => 'AUP Reversal', :MSISDN.to_s => recipient, :amount => amount_to_remove, :validityType.to_s => "N", :validity => 0,
						:freeTime => 0, :freeSMS => 0, :freeMoney => 0, :freeData=> 0  }
				  		remove_response = client.call(:set_account_balances, message: remove_credit)
				  		#add credit 
				  		add_credit = { :operatorName.to_s => 'AUP Reversal', :MSISDN.to_s => sender, :amount => amount_to_reverse, :validityType.to_s => "N", :validity => 0,
						:freeTime => 0, :freeSMS => 0, :freeMoney => 0, :freeData=> 0  }
				  		add_response = client.call(:set_account_balances, message: add_credit)
				  		EvcLog.new(:transid => params[:id], :sender => sender, :recipient => recipient, :amount_sent => amount, :amount_reversed =>amount_to_reverse,
				  			:reverse_type => "Subscriber to Subscriber", :username => session[:username], :fullname => session[:fullname], :ip => request.remote_ip,
				  			:date_sent => reversal.time.to_date, :date => Time.now).save 
				  		flash[:success] = "Success"		
					else
					flash[:success] = "Fail"
					end
				end
			else
				flash[:success] = "This Reversal has already been done"
			end
			redirect_to evc_evc_select_path
		end
	end

	#Reverse Dealer To Dealer Credit
	def reverse_dealer
		if session[:evc_role] == 2 or session[:evc_role] == 1
			reversal = LivefeedSsr.find_by_sql("SELECT * FROM [dbo].[vw_ssrs] WHERE transid = #{params[:id]} order by transid asc").first
			datesent = reversal.time.to_date
			reversal_exists = EvcLog.find_by_sql("SELECT * FROM [dbo].[evc_reverse_logs] WHERE transid = #{params[:id]} and [date_sent] = '#{datesent}'")
			if reversal_exists.blank?	
				amount = reversal.amount
				sender = reversal.cardnum
				recipient = reversal.accnum
				evc_recipient = "161"+recipient.to_s
				client = Savon.client(wsdl: "http://192.168.0.232:8080/axis2/services/WebService?wsdl")
			  	message = { :operatorName.to_s => 'AUP Reversal', :MSISDN.to_s => evc_recipient }
			  	response = client.call(:get_account_details, message: message).xml
			  	Nokogiri::HTML(response).root.children.each do |node|
					@balance = node.at_css('balance').content.to_i
				end
				if @balance > 0
					if @balance >= amount
						amount_to_remove = amount.to_i * -1
						amount_to_reverse = amount.to_i
						#remove dealer credit
						Release8.find_by_sql(["EXEC adddealercredit '#{recipient}',#{amount_to_remove},'AUP Reversal'"])
				  		#add dealer credit 
				  		Release8.find_by_sql(["EXEC adddealercredit '#{sender}',#{amount_to_reverse},'AUP Reversal'"])
				  		EvcLog.new(:transid => params[:id], :sender => sender, :recipient => recipient, :amount_sent => amount, :amount_reversed =>amount_to_reverse,
				  			:reverse_type => "Dealer to Dealer", :username => session[:username], :fullname => session[:fullname], :ip => request.remote_ip,
				  			:date_sent => reversal.time.to_date, :date => Time.now).save
				  		flash[:success] = "Success"
				  		
				  	elsif @balance < amount
				  		amount_to_remove = @balance.to_i * -1
						amount_to_reverse = @balance.to_i
						#remove dealer credit
						Release8.find_by_sql(["EXEC adddealercredit '#{recipient}',#{amount_to_remove},'AUP Reversal'"])
				  		#add dealer credit 
				  		Release8.find_by_sql(["EXEC adddealercredit '#{sender}',#{amount_to_reverse},'AUP Reversal'"])
				  		EvcLog.new(:transid => params[:id], :sender => sender, :recipient => recipient, :amount_sent => amount, :amount_reversed =>amount_to_reverse,
				  			:reverse_type => "Dealer to Dealer", :username => session[:username], :fullname => session[:fullname], :ip => request.remote_ip,
				  			:date_sent => reversal.time.to_date, :date => Time.now).save
				  		flash[:success] = "Success"
				  	else
				  		flash[:success] = "Failed"
					end
				end
			else
				flash[:success] = "This Reversal has already been done"
			end
			redirect_to evc_evc_select_path
		end
	end

	def normal_to_evc
		if session[:evc_role] == 2 or session[:evc_role] == 1
			reversal = LivefeedSsr.find_by_sql("SELECT * FROM [dbo].[vw_ssrs] WHERE transid = #{params[:id]} order by transid asc").first
			datesent = reversal.time.to_date
			reversal_exists = EvcLog.find_by_sql("SELECT * FROM [dbo].[evc_reverse_logs] WHERE transid = #{params[:id]} and [date_sent] = '#{datesent}'")
			if reversal_exists.blank?	
				amount = reversal.amount
				dealer_num = reversal.cardnum
				recipient = reversal.accnum
				client = Savon.client(wsdl: "http://192.168.0.232:8080/axis2/services/WebService?wsdl")
			  	message = { :operatorName.to_s => 'AUP Reversal', :MSISDN.to_s => recipient }
			  	response = client.call(:get_account_details, message: message).xml
			  	Nokogiri::HTML(response).root.children.each do |node|
					@balance = node.at_css('balance').content.to_i
					@free_money = node.at_css('freemoney').content.to_i
				end
				if(amount < 45)
					freemoney = amount * 0.25
				elsif (amount >= 45 and amount < 95)
					freemoney = amount * 0.5
				elsif (amount >= 95 and amount < 125)
					freemoney = amount * 0.75
				elsif (amount >= 125 and amount <= 10000)
					freemoney = amount * 0.8
				end
				if @balance > 0
					if(@balance >= amount.to_i and @free_money >= freemoney.to_i)
						amount_to_remove = amount.to_i * -1
						freemoney_to_remove = freemoney.to_i * -1
						balmessage = { :operatorName.to_s => 'AUP Reversal', :MSISDN.to_s => recipient, :amount=> amount_to_remove, :validityType.to_s => "N", :validity => 0,
						:freeTime => 0, :freeSMS => 0, :freeMoney => freemoney_to_remove, :freeData => 0 }
				  		balresponse = client.call(:set_account_balances, message: balmessage)
				  		#add dealer credit 
				  		Release8.find_by_sql(["EXEC adddealercredit '#{recipient}',#{amount},'AUP Reversal'"])
				  		EvcLog.new(:transid => params[:id], :sender => dealer_num, :recipient => recipient, :amount_sent => amount, :amount_reversed =>amount,
				  			:reverse_type => "Normal To EVC", :username => session[:username], :fullname => session[:fullname], :ip => request.remote_ip,
				  			:date_sent => reversal.time.to_date, :date => Time.now).save
				  		flash[:success] = "Success"

				  	elsif(@balance >= amount.to_i and @free_money < freemoney.to_i)
				  		used_freemoney = freemoney - @free_money
				  		amount_to_reverse = amount - used_freemoney
				  		amount_to_remove = amount.to_i * -1
						freemoney_to_remove = @free_money.to_i * -1
						balmessage = { :operatorName.to_s => 'AUP Reversal', :MSISDN.to_s => recipient, :amount => amount_to_remove, :validityType.to_s => "N", :validity => 0,
						:freeTime => 0, :freeSMS => 0, :freeMoney => freemoney_to_remove, :freeData => 0 }
				  		balresponse = client.call(:set_account_balances, message: balmessage)
				  		#add dealer credit 
				  		Release8.find_by_sql(["EXEC adddealercredit '#{recipient}',#{amount_to_reverse},'AUP Reversal'"])
				  		EvcLog.new(:transid => params[:id], :sender => dealer_num, :recipient => recipient, :amount_sent => amount, :amount_reversed =>amount_to_reverse,
				  			:reverse_type => "Normal To EVC", :username => session[:username], :fullname => session[:fullname], :ip => request.remote_ip,
				  			:date_sent => reversal.time.to_date, :date => Time.now).save
				  		flash[:success] = "Success"
				  		
				  	elsif(@balance < amount.to_i and @free_money >= freemoney.to_i)
				  		amount_to_remove = @balance.to_i * -1
						freemoney_to_remove = freemoney.to_i * -1
						amount_to_reverse = @balance
						balmessage = { :operatorName.to_s => 'AUP Reversal', :MSISDN.to_s => recipient, :amount => amount_to_remove, :validityType.to_s => "N", :validity => 0,
						:freeTime => 0, :freeSMS => 0, :freeMoney => freemoney_to_remove, :freeData=> 0  }
				  		balresponse = client.call(:set_account_balances, message: balmessage)
				  		#add dealer credit 
				  		Release8.find_by_sql(["EXEC adddealercredit '#{recipient}',#{amount_to_reverse},'AUP Reversal'"])
				  		EvcLog.new(:transid => params[:id], :sender => dealer_num, :recipient => recipient, :amount_sent => amount, :amount_reversed =>amount_to_reverse,
				  			:reverse_type => "Normal To EVC", :username => session[:username], :fullname => session[:fullname], :ip => request.remote_ip,
				  			:date_sent => reversal.time.to_date, :date => Time.now).save
				  		flash[:success] = "Success"

				  	elsif(@balance < amount.to_i and @free_money < freemoney.to_i)
				  		used_freemoney = freemoney - @free_money
				  		used_credit = amount.to_i - @balance
				  		amount_to_remove = @balance.to_i * -1
						freemoney_to_remove = @free_money * -1
						amounttoreverse = amount - (used_freemoney + used_credit)
						if amounttoreverse >= 0
							amount_to_reverse = amounttoreverse
						else
							amount_to_reverse = 0
						end
						balmessage = { :operatorName.to_s => 'AUP Reversal', :MSISDN.to_s => recipient, :amount => amount_to_remove, :validityType.to_s => "N", :validity => 0,
						:freeTime => 0, :freeSMS => 0, :freeMoney => freemoney_to_remove, :freeData => 0  }
				  		balresponse = client.call(:set_account_balances, message: balmessage)
				  		#add dealer credit 
				  		Release8.find_by_sql(["EXEC adddealercredit '#{recipient}',#{amount_to_reverse},'AUP Reversal'"])
				  		EvcLog.new(:transid => params[:id], :sender => dealer_num, :recipient => recipient, :amount_sent => amount, :amount_reversed =>amount_to_reverse,
				  			:reverse_type => "Normal To EVC", :username => session[:username], :fullname => session[:fullname], :ip => request.remote_ip,
				  			:date_sent => reversal.time.to_date, :date => Time.now).save
				  		flash[:success] = "Success"
				  	else
				  		flash[:success] = 'Fail'
					end
				end
			else
				flash[:success] = "This Reversal has already been done"
			end
			redirect_to evc_evc_select_path
		end
	end
end
