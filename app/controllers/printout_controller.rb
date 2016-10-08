class PrintoutController < ApplicationController
 
  def evc_select

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

  def evc_printout
    msisdn = params[:msisdn]
    date1= params[:year1]+params[:month1]+params[:day1]
    date2= params[:year2]+params[:month2]+params[:day2]
    session[:date1] = date1
    session[:date2] = date2

      if(session[:report_role] == "mainhall_supervisor" or session[:report_role] == "mainhall_super" or session[:username] == "esaidy")
        # @result = Printout.find_by_sql("SELECT * FROM custcarelogs where role = 'mainhall' and cast(created_at as date) BETWEEN '#{date1}' and '#{date2}'")
        @result = Printout.find_by_sql("select time as changedate , accnum,cardnum,strtbal,case when ssrtype = 91 then  -amount else amount end as amount from [dbo].[vw_ssrs] where accnum ='#{msisdn}'  and ssrtype in (91,92) and time between '#{date1}' and  '#{date2}' order by time asc")
      # elsif(params[:username] == "allusers" and (session[:report_role] == "callcenter_report" or session[:username] == "kkeita"))
      #    @result = Custcarelog.find_by_sql("SELECT * FROM custcarelogs where department = 'Call Center' and cast(created_at as date) BETWEEN '#{date1}' and '#{date2}'")
      # elsif(params[:username] == "allusers" and session[:report_role] == "outlet_supervisor")
      #   @result = Custcarelog.find_by_sql("SELECT * FROM custcarelogs where role = 'outlet' and cast(created_at as date) BETWEEN '#{date1}' and '#{date2}'")
      # elsif(params[:username] == "allusers" and session[:report_role] == "mainhall_super")
      #     @result = Custcarelog.find_by_sql("SELECT * FROM custcarelogs where department = 'Customer care' and cast(created_at as date) BETWEEN '#{date1}' and '#{date2}'") 
      # elsif(params[:username] == "callcenter" and session[:report_role] == "mainhall_super")
      #     @result = Custcarelog.find_by_sql("SELECT * FROM custcarelogs where department = 'Call Center' and cast(created_at as date) BETWEEN '#{date1}' and '#{date2}'")
      # elsif(params[:username] == "allusers" and session[:userrole] == "admin")
      #     @result = Custcarelog.find_by_sql("SELECT * FROM custcarelogs where (department = 'Customer care' or department = 'Call Center') and cast(created_at as date) BETWEEN '#{date1}' and '#{date2}'")
      # elsif(params[:username] == "mainhall" and (session[:report_role] == "mainhall_super" or session[:report_role] == "mainhall_supervisor"))
      #     @result = Custcarelog.find_by_sql("SELECT * FROM custcarelogs where role = 'mainhall' and cast(created_at as date) BETWEEN '#{date1}' and '#{date2}'")
      # else
    	 # @result = Custcarelog.find_by_sql("SELECT * FROM custcarelogs where username = '#{params[:username]}' and cast(created_at as date) BETWEEN '#{date1}' and '#{date2}'")
      end

  	# respond_to do |format|
  	#     format.html
  	#     #format.csv {send_data @result.to_csv}
  	#     format.xls #{send_data @result.to_csv(col_sep: "\t")}
  	# end
  end
end