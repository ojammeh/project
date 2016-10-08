class CdrController < ApplicationController
	protect_from_forgery :except => [:update]

	def view_cdr

		if params[:single_date]

			session[:date_type] = "single_date"
			@date = params[:year].to_s + params[:month].to_s + params[:day].to_s

			@cdrcount = CdrCollection.where(date: @date).order("source")
			@description = "CDR Collection For "+ @date
			
		
		elsif params[:date_range]

			session[:date_type] = "date_range"

			@date1 = params[:year1].to_s + params[:month1].to_s + params[:day1].to_s
			@date2 = params[:year2].to_s + params[:month2].to_s + params[:day2].to_s

			@description = "CDR Collection Between "+ @date1 +" And "+@date2

			@huawei = CdrCollection.where('(date BETWEEN ? AND ?) AND source=?',@date1, @date2,'HUAWEI').order("date")
			@hwbilling = CdrCollection.find(:all, :order => "date", :conditions =>['date BETWEEN ? AND ? AND source=?',@date1, @date2,'HW Billing'])
			@hwdtwh = CdrCollection.find(:all, :order => "date", :conditions =>['date BETWEEN ? AND ? AND source=?',@date1, @date2,'HW DTWH'])
			@hwhq = CdrCollection.find(:all, :order => "date", :conditions =>['date BETWEEN ? AND ? AND source=?',@date1, @date2,'HW HQ'])
			@inaccdtwh = CdrCollection.find(:all, :order => "date", :conditions =>['date BETWEEN ? AND ? AND source=?',@date1, @date2,'IN ACC DTWH'])
			@inacchq = CdrCollection.find(:all, :order => "date", :conditions =>['date BETWEEN ? AND ? AND source=?',@date1, @date2,'IN ACC HQ'])
			@inacchstdtwh = CdrCollection.find(:all, :order => "date", :conditions =>['date BETWEEN ? AND ? AND source=?',@date1, @date2,'IN ACC HST DTWH'])
			@inacchsthq = CdrCollection.find(:all, :order => "date", :conditions =>['date BETWEEN ? AND ? AND source=?',@date1, @date2,'IN ACC HST HQ'])
			@incdrdtwh = CdrCollection.find(:all, :order => "date", :conditions =>['date BETWEEN ? AND ? AND source=?',@date1, @date2,'IN CDR DTWH'])
			@incdrhq = CdrCollection.find(:all, :order => "date", :conditions =>['date BETWEEN ? AND ? AND source=?',@date1, @date2,'IN CDR HQ'])
			@roamingfiles = CdrCollection.find(:all, :order => "date", :conditions =>['date BETWEEN ? AND ? AND source=?',@date1, @date2,'Roaming Files'])
			@hwsgsn = CdrCollection.find(:all, :order => "date", :conditions =>['date BETWEEN ? AND ? AND source=?',@date1, @date2,'HW SGSN'])
			@databilling = CdrCollection.find(:all, :order => "date", :conditions =>['date BETWEEN ? AND ? AND source=?',@date1, @date2,'Data Billing'])
			@datawarehouse = CdrCollection.find(:all, :order => "date", :conditions =>['date BETWEEN ? AND ? AND source=?',@date1, @date2,'Data Warehouse'])
			
			render :layout => "cdr_collection"
			#@users = User.all(:conditions => ["created_at >= ?", Date.today.at_beginning_of_month])
		end
			UserLog.new(:user => session[:fullname], :transaction_type => "CDR", :description => @description, :ip_address =>request.remote_ip, :username => session[:username], :created_at => Time.now).save
	end

	def edit
		@cdr = CdrCollection.find_by_id(params[:id])
	end

	def update	
		@cdr = CdrCollection.find_by_id(params[:id])
		@cdr.update_attributes(:source => params[:source], :file_range => params[:range], :file_count => params[:count], :file_missing => params[:missing])
		flash[:success] = "Update Successful"
		redirect_to cdr_cdr_select_path 
		UserLog.new(:user => session[:fullname], :transaction_type => "CDR", :description => "Upate/edit CDR Page", :ip_address =>request.remote_ip, :username => session[:username], :created_at => Time.now).save
	end
end
