class CashierController < ApplicationController
	protect_from_forgery :except => [:new_product, :update_product]

	def  receipt
		@products = CashierProduct.where(deleted: 0).order("name")
	end

	def  new_receipt
		@product = CashierProduct.find_by_id(params[:being])
		
		@newreceipt = Receipt.new(:customer => params[:name], :product => @product.name, :amount => @product.price, :vat => @product.vat, :msisdn => params[:number], :cashier => session[:fullname])
			if(@newreceipt.save==false)
				flash[:error] = "ERROR!! Cannot create receipt"
				redirect_to :action => :receipt
			end
			render :layout => "receipt"
			UserLog.new(:user => session[:fullname], :transaction_type => "Cashier", :description => "Receipt Generated", :msisdn => params[:number], :ip_address =>request.remote_ip, :name =>params[:name], :username => session[:username], :created_at => Time.now).save
	end

	def new_other_receipt
		@newreceipt = Receipt.new(:customer => params[:name], :product => params[:type], :amount => params[:amount], :description => params[:description], :cheque_number => params[:cheque], :cashier => session[:fullname])
		if(@newreceipt.save==false)
			flash[:error] = "ERROR!! Cannot create receipt"
			redirect_to :action => :receipt
		end
		render :layout => "receipt"
		UserLog.new(:user => session[:fullname], :transaction_type => "Cashier", :description => "Receipt Generated", :msisdn => params[:number], :ip_address =>request.remote_ip, :name =>params[:name], :username => session[:username], :created_at => Time.now).save
	end

	def products
		@products = CashierProduct.where(deleted: 0).order("name")
	end

	def new_product
		newproduct = CashierProduct.new(:name => params[:product], :price => params[:amount], :deleted => 0, :by => session[:fullname])
		if(newproduct.save)
			flash[:success] = "Successfully created product"
			redirect_to :action => :products

			UserLog.new(:user => session[:fullname], :transaction_type => "Cashier", :description => "New Cashier Product added", :ip_address =>request.remote_ip, :username => session[:username], :created_at => Time.now).save
		else 
			flash[:error] = "ERROR!! Cannot save product"
			redirect_to :action => :products
		end
	end

	def edit_product
		@product = CashierProduct.find_by_id(params[:id])
	end

	def update_product
		product = CashierProduct.find_by_id(params[:productid])
		product.update_attributes(:name =>params[:product], :price => params[:amount], :deleted => 0, :updated_by => session[:fullname])
		flash[:success] = "Product Updated"
		redirect_to :action => :products
		UserLog.new(:user => session[:fullname], :transaction_type => "Cashier", :description => "Cashier Product Updated", :ip_address =>request.remote_ip, :username => session[:username], :created_at => Time.now).save
	end

	def delete_product
		product = CashierProduct.find_by_id(params[:id])
		product.update_attributes(:deleted => 1, :updated_by => session[:fullname])
		flash[:success] = "Product Deleted"
		redirect_to :action => :products
		UserLog.new(:user => session[:fullname], :transaction_type => "Cashier", :description => "New Cashier Product Deleted", :ip_address =>request.remote_ip, :username => session[:username], :created_at => Time.now).save
	end

	def c_report
		date1= params[:year1]+params[:month1]+params[:day1]
		date2= params[:year2]+params[:month2]+params[:day2]
		session[:date1] = date1
		session[:date2] = date2
	
    	@result = Receipt.find_by_sql("SELECT * FROM cashier_receipts WHERE cast(created_at as date) BETWEEN '#{date1}' and '#{date2}'")
    	UserLog.new(:user => session[:fullname], :transaction_type => "Cashier", :description => "Cashier Report Generated", :ip_address =>request.remote_ip, :username => session[:username], :created_at => Time.now).save
    	respond_to do |format|
    	format.html	
        format.xls
    	end
	end

	def c_report_xls
    	@result = Receipt.find_by_sql("SELECT * FROM cashier_receipts WHERE cast(created_at as date) BETWEEN '#{session[:date1]}' and '#{session[:date2]}'")
    	UserLog.new(:user => session[:fullname], :transaction_type => "Cashier", :description => "Cashier Report Exported", :ip_address =>request.remote_ip, :username => session[:username], :created_at => Time.now).save
    	respond_to do |format|
        format.xls
    	end
	end
end
