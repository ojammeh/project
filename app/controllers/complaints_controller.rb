class ComplaintsController < ApplicationController

	def search_result
		session[:msisdn] = params[:msisdn]
		@results = Complaint.where('(time_in between ? and ?) and anumber =?',10.days.ago,Time.now, session[:msisdn]).order('time_in DESC')
		registration = SimRegistration.where(phone: session[:msisdn])
		custcareregistration = CustcareRegistration.where(msisdn: session[:msisdn])
		if(custcareregistration.blank? and registration.blank?)
			session[:registered] = "Not Registered"
		end
	end

	def new_complaint
		msisdn = session[:msisdn]

		if params[:newcomplaint]
			customername = params[:name]+" "+params[:l_name]
			Complaint.new(:anumber => msisdn, :complaint => params[:complaint], :category => params[:category], :custcare_user => session[:fullname], :username => session[:username], :time_in =>Time.now, :customer_name => customername, :status => 0, :role => session[:userrole]).save
			Custcarelog.new(:msisdn	=> msisdn, :username => session[:username], :full_name => session[:fullname], :department => session[:department], :role => session[:userrole], :transaction_type => params[:category], :description =>params[:complaint], :action_performed => "New Complaint").save
			if(session[:registered] == "Not Registered")
				CustcareRegistration.new(:msisdn => msisdn, :first_name => params[:name], :last_name => params[:l_name], :id_type => params[:id_type], :id_number => params[:id_number], :custcare_agent => session[:fullname]).save
			end
			#UserLog.new(:user => session[:fullname], :transaction_type => "Custcare Complaints", :description => "New Helpdesk Complaint", :msisdn => params[:number], :ip_address =>request.remote_ip, :name =>params[:name], :username => session[:username], :created_at => Time.now).save
			redirect_to complaints_search_result_path(:msisdn => msisdn) and return
		end

		respond_to do | format |
	    	format.html
	        format.js
		end
	end

	def status
		if(session[:userrole] == "admin")
			@pending = Complaint.where('status =? or status =?',0,1).order('status ASC, time_in ASC')
		elsif(session[:report_role] == "callcenter_supervisor" or session[:userrole] == "callcenter_dialout")
			@pending = Complaint.where('(status =? or status =?) and (role =? or role =?)',0,1,"callcenter","cc").order('status ASC, time_in ASC')
		elsif(session[:report_role] == "mainhall_super")
			@pending = Complaint.where('(status =? or status =?) and (role =? or role =?)',0,1,"mainhall","mainhall_invalid").order('status ASC, time_in ASC')
		elsif(session[:userrole] == "outlet")
			@pending = Complaint.where('(status =? or status =?) and (role =? )',0,1,"outlet").order('status ASC, time_in ASC')
		else 
			@pending = Complaint.where('(status =? or status=?) and username=?',0,1,session[:username]).order('status ASC, time_in ASC')
		end
	end

	def pending_dialout
		@pending = Complaint.where('(status =?) and (role =? or role =? )',2,"callcenter","cc").order('status ASC, time_in ASC')
	end

	def pending
		@pending = Complaint.where(status: 0).order('status ASC, time_in ASC')
	end

	def update_tech
		if params[:updatetech]
			session[:feed].update_attributes(:status => 1, :technical_comments => params[:feedback], :time_out => Time.now, :technical_user => session[:fullname], :not_satisfied => "")
			redirect_to complaints_pending_path and return
		else
			session[:feed] = Complaint.find_by_id(params[:id])
			session[:id] = params[:id]
		end

		respond_to do | format |
	    	format.html
	        format.js
		end

	end

	def not_satisfied
		if params[:notsatisfied]
			session[:id].update_attributes(:complaint => params[:satisfy], :status => 0, :not_satisfied => "Not Satisfied")
			redirect_to complaints_status_path and return
		else
			satisfied = Complaint.find_by_id(params[:id])
			session[:satisfied] = satisfied.complaint
			session[:id] = satisfied
		end
		
		respond_to do | format |
	    	format.html
	        format.js
		end
	end

	def dismiss
		dismiss = Complaint.find_by_id(params[:id])
		dismiss.update_attributes(:status => 2)
		redirect_to complaints_status_path and return
	end

	def dismiss_dialout
		dismiss = Complaint.find_by_id(params[:id])
		dismiss.update_attributes(:status => 3)
		Custcarelog.new(:msisdn	=> dismiss.anumber, :username => session[:username], :full_name => session[:fullname], :department => session[:department], :role => session[:userrole], :transaction_type => "Dial Out", :description => "Completed Complaint Dialout", :action_performed => "Dissmissed").save
		redirect_to complaints_pending_dialout_path and return
	end
end