class AdminController < ApplicationController
  def index
  	 @total_orders = User.count
  end

  def cc_report_select

    if(session[:report_role] == "mainhall_supervisor")
      @allusers = User.where(role: "mainhall").order('full_name')
    elsif(session[:report_role] == "callcenter_report" or session[:username] == "kkeita")
      @allusers = User.where(role: "callcenter").order('full_name')
    elsif(session[:report_role] == "outlet_supervisor")
        @allusers = User.where(role: "outlet").order('full_name')
    elsif(session[:report_role] == "mainhall_super")
      @allusers = User.where(department: "Customer Care").order('full_name')
    elsif(session[:userrole] == "admin")
      @allusers = User.where('department =? or department=?',"Customer Care","Call Center").order('full_name')
    end
  end

  def manifest_report_select
    if((session[:report_role] == "mainhall_supervisor") or (session[:report_role] == "mainhall_super"))
      @allusers = User.where(role: "mainhall").order('full_name')
    elsif(session[:report_role] == "outlet_supervisor")
      @allusers = User.where(role: "outlet").order('full_name')
    elsif(session[:userrole] == "admin")
      @allusers = User.where('department =?',"Customer Care").order('full_name')
    end
  end

  def cc_report
    session[:usern] = params[:username]
    date1= params[:year1]+params[:month1]+params[:day1]
    date2= params[:year2]+params[:month2]+params[:day2]
    session[:date1] = date1
    session[:date2] = date2

     if(session[:report_role] == "mainhall_supervisor")
        @allusers = User.where(role: "mainhall").order('full_name')
      elsif(session[:report_role] == "callcenter_report" or session[:username] == "kkeita")
        @allusers = User.where(role: "callcenter").order('full_name')
      elsif(session[:report_role] == "outlet_supervisor")
          @allusers = User.where(role: "outlet").order('full_name')
      elsif(session[:report_role] == "mainhall_super")
        @allusers = User.where(department: "Customer Care").order('full_name')
      elsif(session[:userrole] == "admin")
        @allusers = User.where('department =? or department=?',"Customer Care","Call Center").order('full_name')
      end

      if(params[:username] == "allusers" and session[:report_role] == "mainhall_supervisor")
        @result = Custcarelog.find_by_sql("SELECT * FROM custcarelogs where role = 'mainhall' and cast(created_at as date) BETWEEN '#{date1}' and '#{date2}'")
      elsif(params[:username] == "allusers" and (session[:report_role] == "callcenter_report" or session[:username] == "kkeita"))
         @result = Custcarelog.find_by_sql("SELECT * FROM custcarelogs where department = 'Call Center' and cast(created_at as date) BETWEEN '#{date1}' and '#{date2}'")
      elsif(params[:username] == "allusers" and session[:report_role] == "outlet_supervisor")
        @result = Custcarelog.find_by_sql("SELECT * FROM custcarelogs where role = 'outlet' and cast(created_at as date) BETWEEN '#{date1}' and '#{date2}'")
      elsif(params[:username] == "allusers" and session[:report_role] == "mainhall_super")
          @result = Custcarelog.find_by_sql("SELECT * FROM custcarelogs where department = 'Customer care' and cast(created_at as date) BETWEEN '#{date1}' and '#{date2}'") 
      elsif(params[:username] == "callcenter" and session[:report_role] == "mainhall_super")
          @result = Custcarelog.find_by_sql("SELECT * FROM custcarelogs where department = 'Call Center' and cast(created_at as date) BETWEEN '#{date1}' and '#{date2}'")
      elsif(params[:username] == "allusers" and session[:userrole] == "admin")
          @result = Custcarelog.find_by_sql("SELECT * FROM custcarelogs where (department = 'Customer care' or department = 'Call Center') and cast(created_at as date) BETWEEN '#{date1}' and '#{date2}'")
      elsif(params[:username] == "mainhall" and (session[:report_role] == "mainhall_super" or session[:report_role] == "mainhall_supervisor"))
          @result = Custcarelog.find_by_sql("SELECT * FROM custcarelogs where role = 'mainhall' and cast(created_at as date) BETWEEN '#{date1}' and '#{date2}'")
      else
    	 @result = Custcarelog.find_by_sql("SELECT * FROM custcarelogs where username = '#{params[:username]}' and cast(created_at as date) BETWEEN '#{date1}' and '#{date2}'")
      end

  	respond_to do |format|
  	    format.html
  	    #format.csv {send_data @result.to_csv}
  	    format.xls #{send_data @result.to_csv(col_sep: "\t")}
  	end
  end

  def manifest_report

    session[:usern] = params[:username]
    date1= params[:year1]+params[:month1]+params[:day1]
    date2= params[:year2]+params[:month2]+params[:day2]
    session[:date1] = date1
    session[:date2] = date2

    if((session[:report_role] == "mainhall_supervisor") or (session[:report_role] == "mainhall_super"))
      @allusers = User.where(role: "mainhall").order('full_name')
    elsif(session[:report_role] == "outlet_supervisor")
      @allusers = User.where(role: "outlet").order('full_name')
    elsif(session[:userrole] == "admin")
      @allusers = User.where('role =? or role =?',"mainhall","outlet").order('full_name')
    end

    if(params[:username] == "allusers" and session[:report_role] == "mainhall_supervisor")
      @result = Manifest.find_by_sql("SELECT * FROM sim_manifest where role = 'mainhall' and cast(created_at as date) BETWEEN '#{date1}' and '#{date2}'")
    elsif(params[:username] == "allusers" and session[:report_role] == "outlet_supervisor")
       @result = Manifest.find_by_sql("SELECT * FROM sim_manifest where role = 'outlet' and cast(created_at as date) BETWEEN '#{date1}' and '#{date2}'")
    elsif(params[:username] == "allusers" and session[:userrole] == "admin")
      @result = Manifest.find_by_sql("SELECT * FROM sim_manifest where role = 'mainhall' or role ='outlet' and cast(created_at as date) BETWEEN '#{date1}' and '#{date2}'")
    else
      @result = Manifest.find_by_sql("SELECT * FROM sim_manifest where username = '#{params[:username]}' and cast(created_at as date) BETWEEN '#{date1}' and '#{date2}'")
    end

    respond_to do |format|
        format.html
        #format.csv {send_data @result.to_csv}
        format.xls #{send_data @result.to_csv(col_sep: "\t")}
    end
  end

  def cc_report_xls
      if(session[:usern] == "allusers" and session[:report_role] == "mainhall_supervisor")
        @result = Custcarelog.find_by_sql("SELECT * FROM custcarelogs where role = 'mainhall' and cast(created_at as date) BETWEEN '#{session[:date1]}' and '#{session[:date2]}'")
      elsif(session[:usern] == "allusers" and (session[:report_role] == "callcenter_report" or session[:username] == "kkeita"))
         @result = Custcarelog.find_by_sql("SELECT * FROM custcarelogs where department = 'Call Center' and cast(created_at as date) BETWEEN '#{session[:date1]}' and '#{session[:date2]}'")
      elsif(session[:usern] == "allusers" and session[:report_role] == "outlet_supervisor")
        @result = Custcarelog.find_by_sql("SELECT * FROM custcarelogs where role = 'outlet' and cast(created_at as date) BETWEEN '#{session[:date1]}' and '#{session[:date2]}'")
      elsif(session[:usern] == "allusers" and session[:report_role] == "mainhall_super")
        @result = Custcarelog.find_by_sql("SELECT * FROM custcarelogs where department = 'Customer care' and cast(created_at as date) BETWEEN '#{session[:date1]}' and '#{session[:date2]}'")
      elsif(session[:usern] == "callcenter" and session[:report_role] == "mainhall_super")
        @result = Custcarelog.find_by_sql("SELECT * FROM custcarelogs where department = 'Call Center' and cast(created_at as date) BETWEEN '#{session[:date1]}' and '#{session[:date2]}'")
      elsif(session[:usern] == "allusers" and session[:userrole] == "admin")
        @result = Custcarelog.find_by_sql("SELECT * FROM custcarelogs where (department = 'Customer care' or department = 'Call Center') and cast(created_at as date) BETWEEN '#{session[:date1]}' and '#{session[:date2]}'")
      elsif(session[:usern] == "mainhall" and (session[:report_role] == "mainhall_super" or session[:report_role] == "mainhall_supervisor"))
        @result = Custcarelog.find_by_sql("SELECT * FROM custcarelogs where (role = 'mainhall') and cast(created_at as date) BETWEEN '#{session[:date1]}' and '#{session[:date2]}'")
      else
       @result = Custcarelog.find_by_sql("SELECT * FROM custcarelogs where username = '#{session[:usern]}' and cast(created_at as date) BETWEEN '#{session[:date1]}' and '#{session[:date2]}'")
      end

    respond_to do |format|
        format.xls
    end
  end

  def manifest_report_xls
    if(session[:usern] == "allusers" and session[:report_role] == "mainhall_supervisor")
      @result = Manifest.find_by_sql("SELECT * FROM sim_manifest where role = 'mainhall' and cast(created_at as date) BETWEEN '#{session[:date1]}' and '#{session[:date2]}'")
    elsif(session[:usern] == "allusers" and session[:report_role] == "outlet_supervisor")
       @result = Manifest.find_by_sql("SELECT * FROM sim_manifest where role = 'outlet' and cast(created_at as date) BETWEEN '#{session[:date1]}' and '#{session[:date2]}'")
    elsif(session[:usern] == "allusers" and session[:userrole] == "admin")
      @result = Manifest.find_by_sql("SELECT * FROM sim_manifest where role = 'mainhall' or role ='outlet' and cast(created_at as date) BETWEEN '#{session[:date1]}' and '#{session[:date2]}'")
    else
      @result = Manifest.find_by_sql("SELECT * FROM sim_manifest where username = '#{session[:usern]}' and cast(created_at as date) BETWEEN '#{session[:date1]}' and '#{session[:date2]}'")
    end
  end
end