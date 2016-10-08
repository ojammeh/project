class SessionsController < ApplicationController
	skip_before_action :authorize

  def new
  	render :layout => "login"
  end

 def create
    user = User.find_by(name: params[:name])
    if user and user.authenticate(params[:password])
      session[:user_id] = user.id
      session[:username] = user.name
      session[:userrole] = user.role
      session[:fullname] = user.full_name
      session[:department] = user.department
      session[:report_role] = user.report_role
      session[:evc_role] = user.evc
      session[:desk_role] = user.desk_role
      session[:shop_role] = user.shop_role
      session[:bank_role] = user.bank_role
      redirect_to admin_url
    else
      #redirect_to login_url, alert: "Invalid user/password combination"

      flash[:error] = "ERROR!! Invalid User/Password Combination"
      redirect_to login_url
    end

  end

  def destroy
    session[:user_id] = nil
    session[:username] = nil
    session[:userrole] = nil
    session[:fullname] = nil
    session[:department] = nil
    session[:report_role] = nil
    session[:evc_role] = nil
    session[:desk_first_name] = nil
    session[:desk_last_name] = nil
    session[:desk_msisdn] = nil
    session[:desk_id_type] = nil
    session[:desk_id_number] = nil
    session[:desk_address] = nil
    session[:desk_user_id] = nil
    session[:desk_status] = nil
    session[:desk_id] = nil
    session[:shop_role] = nil
    session[:bank_role] = nil
    redirect_to index_path #, notice: "Logged out"
    #render :layout => "subdetails"
  end
end
