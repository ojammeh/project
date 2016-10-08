class HlrController < ApplicationController

	def hlr_output    # when the user sends a request process it using a GET 

 	if request.get?
 		msisdn = params[:msisdn]
 		command = params[:command]
 		user = "BSUWEB"
 		password = "BSU@123"
 		gateway = "192.167.0.12"
 		@result = ""
 		hlr = Hlr.new


 	#@log = UserLog.new(:user => @session['user'].name, :transaction_type => "HLR", :description => "#{command} for #{msisdn}", :ip_address =>@client_ip, :created_at => Time.now, :msisdn => msisdn)
      #@log.save

 		case(command)
 			 when 'DISPLAY'  then
 			 	@builtCommand = hlr.buildCommand(command,msisdn,'TRUE',nil,nil,nil,nil,nil,nil,nil,nil)
 			 	@result = hlr.execute(command,gateway,user,password,msisdn,'TRUE',nil,nil,nil,nil,nil,nil,nil,nil)


 			 	when 'DISPDYN'  then
 			 	@builtCommand = hlr.buildCommand(command,msisdn,'TRUE',nil,nil,nil,nil,nil,nil,nil,nil)
 			 	@result = hlr.execute(command,gateway,user,password,msisdn,'TRUE',nil,nil,nil,nil,nil,nil,nil,nil)

 		      when 'DISPLAYKI'
 		      	@builtCommand = hlr.buildCommand(command,msisdn,nil,nil,nil,nil,nil,nil,nil,nil,nil)
 			 	@result = hlr.execute(command,gateway,user,password,msisdn,nil,nil,nil,nil,nil,nil,nil,nil,nil)

 		  	 when 'BARIC' then # user chose to bar incoming calls
 				@builtCommand = hlr.buildCommand(command,msisdn,'BAIC',nil,nil,nil,nil,nil,nil,nil,nil)
 				@result = hlr.execute(command,gateway,user,password,msisdn,'BAIC',nil,nil,nil,nil,nil,nil,nil,nil)

 			when 'BAROC' then # user chose to bar outgoing calls
 				@builtCommand = hlr.buildCommand(command,msisdn,'BAOC',nil,nil,nil,nil,nil,nil,nil,nil)
 				@result = hlr.execute(command,gateway,user,password,msisdn,'BAOC',nil,nil,nil,nil,nil,nil,nil,nil)

 			when 'UBAROC' then # user chose to un-bar outgoing
 				@builtCommand = hlr.buildCommand('BAROC',msisdn,'NOBOC',nil,nil,nil,nil,nil,nil,nil,nil)
 				@result = hlr.execute('BAROC',gateway,user,password,msisdn,'NOBOC',nil,nil,nil,nil,nil,nil,nil,nil)

 			when 'UBARIC' then # user chose to un-bar outgoing
 				@builtCommand = hlr.buildCommand('BARIC',msisdn,'NOBIC',nil,nil,nil,nil,nil,nil,nil,nil)
 				@result = hlr.execute('BARIC',gateway,user,password,msisdn,'NOBIC',nil,nil,nil,nil,nil,nil,nil,nil)

 			when 'BAROAM' then # user chose to bar roaming calls
 				@builtCommand = hlr.buildCommand('BAROAM',msisdn,'BROHPLMN',nil,nil,nil,nil,nil,nil,nil,nil)
 				@result = hlr.execute('BAROAM',gateway,user,password,msisdn,'BROHPLMN',nil,nil,nil,nil,nil,nil,nil,nil)

 			when 'UBAROAM' then # user chose to un-bar roaming calls
 				@builtCommand = hlr.buildCommand('BAROAM',msisdn,'NOBAR',nil,nil,nil,nil,nil,nil,nil,nil)
 				@result = hlr.execute('BAROAM',gateway,user,password,msisdn,'NOBAR',nil,nil,nil,nil,nil,nil,nil,nil)

 			when 'PROVGPRS' then # user chose to activate  GPRS service for a subscriber
 				@builtCommand = hlr.buildCommand('MODNAM',msisdn,'TRUE','1',nil,nil,nil,nil,nil,nil,nil)
 				@result = hlr.execute('PROVGPRS',gateway,user,password,msisdn,'TRUE','1',nil,nil,nil,nil,nil,nil,nil)
				
				@builtCommand = hlr.buildCommand('MODTPL',msisdn,'TRUE','1',nil,nil,nil,nil,nil,nil,nil)
 				@result = @result+hlr.execute('PROVGPRS',gateway,user,password,msisdn,'TRUE','1',nil,nil,nil,nil,nil,nil,nil)
				
				@builtCommand = hlr.buildCommand('MODARD',msisdn,'TRUE','FALSE',nil,nil,nil,nil,nil,nil,nil)
 				@result = @result+hlr.execute('PROVGPRS',gateway,user,password,msisdn,'TRUE','1',nil,nil,nil,nil,nil,nil,nil)				

			when 'PROVCF' then # user chose to activate  Call forward service
 				@builtCommand = hlr.buildCommand('PROVCF',msisdn,'','NOBRCF',nil,nil,nil,nil,nil,nil,nil)
 				@result = hlr.execute('PROVCF',gateway,user,password,msisdn,'NOBRCF',nil,nil,nil,nil,nil,nil,nil,nil)

 			when 'UPROVCF' then # user chose to activate  Call forward service
 				@builtCommand = hlr.buildCommand('PROVCF',msisdn,'','BRACF',nil,nil,nil,nil,nil,nil,nil)
 				@result = hlr.execute('PROVCF',gateway,user,password,msisdn,'BRACF',nil,nil,nil,nil,nil,nil,nil,nil)

 			when 'DISPLAYGPRSTPL' then # user chose to display the list of defined GPRS templates
 				@builtCommand = hlr.buildCommand('DISPLAYGPRSTPL','1',nil,nil,nil,nil,nil,nil,nil,nil,nil)
 				@result = hlr.execute('DISPLAYGPRSTPL',gateway,user,password,'1',nil,nil,nil,nil,nil,nil,nil,nil,nil)
				
				
			when 'REMOVEGPRS' then # user chose to display the list of defined GPRS templates
 				@builtCommand = hlr.buildCommand('REMOVETPLGPRS',msisdn,'FALSE',nil,nil,nil,nil,nil,nil,nil,nil)
 				@result = hlr.execute('REMOVETPLGPRS',gateway,user,password,msisdn,'FALSE',nil,nil,nil,nil,nil,nil,nil,nil)	

 				@builtCommand = hlr.buildCommand('REMOVEUTRAN','TRUE',msisdn,'TRUE','FALSE',nil,nil,nil,nil,nil,nil)
 				@result = @result+hlr.execute('REMOVEUTRAN',gateway,user,password,'TRUE',msisdn,'TRUE','FALSE',nil,nil,nil,nil,nil,nil)				


 			when 'DISPLAYGPRS' then # user chose to display GPRS
 				@builtCommand = hlr.buildCommand('DISPLAYGPRS',msisdn,nil,nil,nil,nil,nil,nil,nil,nil,nil)
 				@result = hlr.execute('DISPLAYGPRS',gateway,user,password,msisdn,nil,nil,nil,nil,nil,nil,nil,nil,nil)

 				when 'LOCK' then # user chose to display GPRS
 				@builtCommand = hlr.buildCommand('LOCK',msisdn,'TRUE','FALSE',nil,nil,nil,nil,nil,nil,nil)
 				@result = hlr.execute('LOCK',gateway,user,password,msisdn,'TRUE','FALSE',nil,nil,nil,nil,nil,nil,nil)

 				when 'UNLOCK' then # user chose to display GPRS
 				@builtCommand = hlr.buildCommand('UNLOCK',msisdn,'FALSE','FALSE',nil,nil,nil,nil,nil,nil,nil)
 				@result = hlr.execute('UNLOCK',gateway,user,password,msisdn,'FALSE','FALSE',nil,nil,nil,nil,nil,nil,nil)
				
				when 'CLIRTEMP' then # user chose to display GPRS
 				@builtCommand = hlr.buildCommand('CLIRTEMP',msisdn,'TRUE','TEMPALLOWED',nil,nil,nil,nil,nil,nil,nil)
 				@result = hlr.execute('CLIRTEMP',gateway,user,password,msisdn,'TRUE','TEMPALLOWED',nil,nil,nil,nil,nil,nil,nil)
				
				when 'CLIRPERM' then # user chose to display GPRS
 				@builtCommand = hlr.buildCommand('CLIRPERM',msisdn,'TRUE','PERMANENT',nil,nil,nil,nil,nil,nil,nil)
 				@result = hlr.execute('CLIRPERM',gateway,user,password,msisdn,'TRUE','PERMANENT',nil,nil,nil,nil,nil,nil,nil)
				
				when 'CLIRREM' then # user chose to display GPRS
 				@builtCommand = hlr.buildCommand('CLIRREM',msisdn,'FALSE',nil,nil,nil,nil,nil,nil,nil,nil)
 				@result = hlr.execute('CLIRREM',gateway,user,password,msisdn,'FALSE',nil,nil,nil,nil,nil,nil,nil,nil)

 				when 'REMOVESUB' then # user chose to display GPRS
 				@builtCommand = hlr.buildCommand(command,msisdn,'TRUE',nil,nil,nil,nil,nil,nil,nil,nil)
 				@result = hlr.execute(command,gateway,user,password,msisdn,'TRUE',nil,nil,nil,nil,nil,nil,nil,nil)

 			when 'MODROGPRS' then # user chose to display GPRS				
				@builtCommand = hlr.buildCommand('MODTPL',msisdn,'TRUE','2',nil,nil,nil,nil,nil,nil,nil)
 				@result = hlr.execute('MODTPL',gateway,user,password,msisdn,'TRUE','2',nil,nil,nil,nil,nil,nil,nil)
 			end
 		end
 	end

	def hlr_send

	 	
	 	msisdn = @params[:msisdn]
	 	command = @params[:command]
	 	user = "BSUWEB"
	 	password = "BSU@123"
	 	gateway = "192.167.0.12"
	 	@result = ""

	 	case(command)
		when "DISPLAY" then @result = Hlr.new.display(gateway,user,password,msisdn)

		@formated = @result.split(", ")
	 	end	

	end

	def create_subscriber
	 	if request.get?
	 		
	 		imsi = params[:msin]
	 		@a4ki = KhavasControl.where(MSIN: imsi).first.A4KI
	        @a4ki = @a4ki.gsub('-',"")
	        msisdn = params[:msisdn]
	 		command = params[:command]
	 		user = "BSUWEB"
	 		password = "BSU@123"
	 		gateway = "192.167.0.12"
	 		@result = ""
	 		hlr = Hlr.new


	 		case(command)
	 			when 'CREATEAC'  then
	 			 	@builtCommand = hlr.buildCommand(command,'1','SIM','COMP128_2','60702'+imsi,@a4ki,'1',nil,nil,nil,nil)
	 			 	@result = hlr.execute(command,gateway,user,password,'1','SIM','COMP128_2','60702'+imsi,@a4ki,'1',nil,nil,nil,nil)

	 		     when 'CREATESUB'
	 		      	@builtCommand = hlr.buildCommand(command,'1','60702'+imsi,'220'+msisdn,'1',nil,nil,nil,nil,nil,nil)
	 			 	@result = hlr.execute(command,gateway,user,password,'1','60702'+imsi,'220'+msisdn,'1',nil,nil,nil,nil,nil,nil)
	 		end
	 	end
 	end
end
