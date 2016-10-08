class ApplicationController < ActionController::Base
 before_action :authorize
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
    # ...

  protected

    def authorize
      unless User.find_by(id: session[:user_id])
        redirect_to login_url #, notice: "Please log in"
      end
   
    #mainhall help desk
      free_agent =  Customer.where(user_id: session[:user_id]).where(status: 0)
      if free_agent.blank?
        @free_agent = 'free'
      end
      if session[:user_id] != nil
        count = Customer.find_by_sql("SELECT count(*) as count FROM `customers` WHERE `status` = 0 and user_id = #{session[:user_id]}").first
        @count =  count.count
      end
    end
 
end
