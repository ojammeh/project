class CustomersController < ApplicationController
  
	# protect_from_forgery :except =>[:new_customer, :update_customer, :delete_customer]
 #  def new_customer
 #  		@user = User.find_by_id(:id)
	# 	Customer.new(:user_name => params[:name], :first_name => params[:fname], :last_name => params[:lname], :msisdn => params[:number], :id_type => params[:idtype],
	# 		:id_number => params[:idnumber], :address => params[:address], :user_id => params[:id]).save
		
	# 	redirect_to :controller => 'users', :action => 'index' 
	# end

	# def view_customers
	# 	@customers = Customer.all

	# end
 #   def create

	# # end
	# end
	# def assign
	# 	@user = User.find_by_id(params[:id])
	# 	@customers = Customer.where(user_id: @user)
	# end
	# def select
	# 	# @customer = Customer.where(:user_id => session[:email])
	# 	# @customers = Customer.all
	# 	@user = User.find_by_id(params[:id])
	# 	@customers = Customer.where(user_id: @user)
	# end

	protect_from_forgery :except =>[:new_customer, :update]

  def new_customer
  	@user = User.find_by_id(:id)
		Customer.new(:first_name => params[:fname], :last_name => params[:lname], :msisdn => params[:number], :user_id => params[:id], :status => params[:status]).save

		redirect_to :controller => 'customers', :action => 'index'
		# redirect_to (:back)
	end

	def index
		@counts = Customer.select("users.*, customers.*").joins(:user).where(status: 0).group(:user_id).count(:user_id)
		@users = User.where(role: "mainhall").order('full_name')
# 		@totals = Customer.find_by_sql("SELECT user_id,count(*) as TOTAL from customers
# WHERE user_id is NOT null and cast(updated_at AS date) ='2016-05-09'
# Group BY user_id")
		@totals = Customer.where("DATE(created_at) = ?", Date.today).group(:user_id).count(:user_id)
	end

	def show
		@user = User.find(params[:id])
	end
	def new
		@user = User.new
	end
	def create
		@user = User.new(user_params)
		if @user.save
		log_in @user
		flash[:success] = "Welcome to the Help Desk"
		redirect_to @user
	else
		render 'new'
	end
	end

	def select
		@customers = Customer.where(user_id: session[:user_id]).where(status: 0)
	end
	# def update
	# 	customer = Customer.find_by_id(params[:id])

	# end
	def done
		# @customer = Customer.find_by_id(params[:id])
		@customer.update_attributes(:id => params[:id], :first_name => params[:fname], :last_name => params[:lname], :msisdn => params[:number], :id_type => params[:idtype],
			:id_number => params[:idnumber], :address => params[:address], :user_id => params[:user_id], :status => params[:status])

		redirect_to (:back)

	end

	def edit
		@user = User.find(params[:id])
	end

	def assign
		@user = User.find_by_id(params[:id])
		@customers = Customer.where(user_id: @user)
	end

	def customer_details
		session[:desk_first_name] = params[:fname]
		session[:desk_last_name] = params[:lname]
		session[:desk_msisdn] = params[:number]
		session[:desk_id_type] = params[:idtype]
		session[:desk_id_number] = params[:idnumber]
		session[:desk_address] = params[:address]
		session[:desk_user_id] = params[:user_id]
		session[:desk_status] = params[:status]
		session[:desk_id] = params[:id]
		redirect_to admin_url
	end

	def update
		if session[:desk_id] != nil
			@customer = Customer.find_by_id(session[:desk_id])
			@customer.update_attributes(:first_name =>session[:desk_first_name], :last_name => session[:desk_last_name], :msisdn => session[:desk_msisdn], :id_type => session[:desk_id_type],
				:id_number => session[:desk_id_number], :address => session[:desk_address], :user_id => session[:desk_user_id], :status => session[:desk_status])
			
			session[:desk_first_name] = nil
			session[:desk_last_name] = nil
			session[:desk_msisdn] = nil
			session[:desk_id_type] = nil
			session[:desk_id_number] = nil
			session[:desk_address] = nil
			session[:desk_user_id] = nil
			session[:desk_status] = nil
			session[:desk_id] = nil
		end
		redirect_to customers_select_path
	end

	def destroy
	User.find(params[:id]).destroy
	flash[:success] = "User deleted"
	redirect_to users_url
	end

	private
		def user_params
			params.require(:user).permit(:name, :email, :password,
			:password_confirmation)
	end

	private
		def update_params
			params.require(:customer).permit(:id, :fname, :lname, :number, :idtype, :idnumber, :address, :user_id)
	end

	# Before filters
	# Confirms a logged-in user.
	def logged_in_user
		unless logged_in?
		store_location
		flash[:danger] = "Please log in."
		redirect_to login_url
		end
	end


	# # Confirms the correct user.
	def correct_user
		@user = User.find(params[:id])
		redirect_to(root_url) unless @user == current_user
	end

	# Confirms an admin user.
	def admin_user
		redirect_to(root_url) unless current_user.admin?
	end
end
