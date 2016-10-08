class DatawarehouseController < ApplicationController

	def track_msisdn
		@dates = TrackerDate.where(track_type: "MSISDN")
	end

	def track_imei
		@dates = TrackerDate.where(track_type: "IMEI")
	end

	def msisdn_tracker
		@dates = TrackerDate.where(track_type: "MSISDN")
		msisdn = "220"+params[:msisdn]
		cdr = TrackerDate.where(:month_year => params[:date], :track_type => "MSISDN").first
		view = cdr.view
		@result = Tracker.find_by_sql("SELECT * FROM #{view} WHERE ServedMSIsdn = '#{msisdn}' ORDER BY StartDate, StartTime")
		UserLog.new(:user => session[:fullname], :transaction_type => "Data Warehouse", :description => "MSISDN Tracker", :msisdn => msisdn, :ip_address =>request.remote_ip, :username => session[:username], :created_at => Time.now).save	
	end

	def imei_tracker
		@dates = TrackerDate.where(track_type: "IMEI")
		@client_ip = request.remote_ip 
	    imei = params[:imei]+"%"
	    cdr = TrackerDate.where(:month_year => params[:date], :track_type => "IMEI").first
		view = cdr.view
		@result = Tracker.find_by_sql("SELECT * FROM #{view} WHERE servedimei Like '#{imei}' ORDER BY startofchargingdate, tmstamp")
		UserLog.new(:user => session[:fullname], :transaction_type => "Data Warehouse", :description => "IMEI Tracker", :msisdn => imei, :ip_address =>request.remote_ip, :username => session[:username], :created_at => Time.now).save
	end

	def subscriber_details
	   	msisdn = params[:msisdn]
	   	ndc = params[:msisdn][0..0]
		isdn = params[:msisdn][1..6]
	   	@sim_registration = SimRegistration.where("phone =? or r_phone =?",msisdn,msisdn)
	   	@smart_registration = SmartRegistration.find_by_sql("SELECT TOP 1 * FROM [dbo].[tbl_registration] WHERE SIMNDC+SIMMSISDN ='#{msisdn}'").first #.first#SIMNDC: ndc).where(SIMMSISDN: isdn).where(flag: 1).first
	   	if !@sim_registration.blank?
	   		@reg = "true"
	   	end
	   	if !@smart_registration.blank?
	   		#@smart_reg = SmartRegistration.where(SIMNDC: ndc).where(SIMMSISDN: isdn).where(flag: 1).first
	   		@smartreg = "smart"
	   		picc1 = @smart_registration.PersonalImage
			picc2 = @smart_registration.IdSide1Image
			picc3 = @smart_registration.IdSide2Image
			pic1 = picc1.gsub!(/\\/, '/')
			pic2 = picc2.gsub!(/\\/, '/')
			pic3 = picc3.gsub!(/\\/, '/')

			@personalpic = 'regimages/'+pic1.split('/')[3]+'/'+pic1.split('/')[-1]+'.jpg'
			@frontpic = 'regimages/'+pic2.split('/')[3]+'/'+pic2.split('/')[-1]+'.jpg'
			@backpic = 'regimages/'+pic3.split('/')[3]+'/'+pic3.split('/')[-1]+'.jpg'
	   	end
	   	if @sim_registration.blank? and @smart_reg.blank?
	   		avatarreg = AvatarDetail.where(msisdn: params[:msisdn]).first
	   		if avatarreg.blank?
		   		@avatar = "true"
		   		@sim_registration = Avatar.find_by_sql("SELECT TOP 1 name FROM avatars ORDER BY NEWID()").first
		   		address = Avatar.find_by_sql("SELECT TOP 1 address FROM [dbo].[avatar_addresses] ORDER BY NEWID()")
		   		address.each do |add|
		   			@address = add.address
		   		end
		   		client = Savon.client(wsdl: "http://192.168.0.232:8080/axis2/services/WebService?wsdl")
				message = { :operatorName.to_s => 'AUP', :MSISDN.to_s => msisdn }
				response = client.call(:get_account_details, message: message).xml
				Nokogiri::HTML(response).root.children.each do |node|
					@firstuse = node.at_css('firstuse').content
					@resulttext = node.at_css('resulttext').content
				end
				if @resulttext == "Successful"
					@created_at = @firstuse.to_date
				end
		   		@name = @sim_registration.name
		   		@msisdn = msisdn
		   		#@created_at = 97.days.ago
		   		#myArray = ["20", "30", "40", "50", "60", "70"]
				#pre_id = myArray[rand(myArray.length)]
				#end_id = 10_000_000 + Random.rand(99_000_000 - 10_000_000)
				idnum = Avatar.find_by_sql("SELECT TOP 1 * FROM recycled where id_type = 'biometric' ORDER BY NEWID()").first
		   		#@id_number = pre_id + end_id.to_s
		   		@id_number = idnum.id_number
		   		@id_type = "biometric"
		   		@sales_person = "Outlet"
		   		AvatarDetail.new(:name => @name, :id_type => @id_type, :id_number => @id_number, :sales_person =>@sales_person, 
				:created_at => @created_at, :msisdn => @msisdn, :address => @address.to_s).save
		   	else
		   		@avatar = "avatar_reg"
		   		@name = avatarreg.name
		   		@msisdn = avatarreg.msisdn
		   		@created_at = avatarreg.created_at
		   		@id_number = avatarreg.id_number
		   		@id_type = avatarreg.id_type
		   		@sales_person = avatarreg.sales_person
		   		@address = avatarreg.address
		   	end
	   	end
	   	@subscriber_registration = SubscriberRegistration.where(phone: msisdn)
	   	@recycled = Recycled.where("phone =? or r_phone =?",msisdn,msisdn)
	   	@receipts = Receipt.where(msisdn: msisdn)
	   	@complaints = Complaint.where(anumber: msisdn)
	   	@invalid = UserLog.where("msisdn =? and transaction_type =?",msisdn,"Invalid Cards")
	   	@cos = Manifest.where(msisdn: msisdn)
	   	UserLog.new(:user => session[:fullname], :transaction_type => "Data Warehouse", :description => "Subscriber Details Query", :msisdn => msisdn, :ip_address =>request.remote_ip, :username => session[:username], :created_at => Time.now).save
	end

	def sub_details

		msisdn = params[:msisdn]

	   	@sim_registration = SimRegistration.where("phone =? or r_phone =?",msisdn,msisdn)
	   	@subscriber_registration = SubscriberRegistration.where(phone: msisdn)
	   	@recycled = Recycled.where("phone =? or r_phone =?",msisdn,msisdn)
	   	@receipts = Receipt.where(msisdn: msisdn)
	   	@complaints = Complaint.where(anumber: msisdn)
	   	@invalid = UserLog.where("msisdn =? and transaction_type =?",msisdn,"Invalid Cards")
	   	@cos = Manifest.where(msisdn: msisdn)
	   	UserLog.new(:user => session[:fullname], :transaction_type => "Data Warehouse", :description => "Subscriber Details Query", :msisdn => msisdn, :ip_address =>request.remote_ip, :username => session[:username], :created_at => Time.now).save
	   	render :layout => "subdetails"

	end

	def back_office_logs
		@users = User.all.order("full_name")
	end

	def office_logs
		@users = User.all.order("full_name")

		@logs = UserLog.where(user: params[:user]).order("created_at Desc").page(params[:page]).per(200)
			#UserLog.new(:user => session[:fullname], :transaction_type => "Data Warehouse", :description => "Subscriber Details Query" :ip_address =>request.remote_ip, :username => session[:username], :created_at => Time.now).save
	end
end
