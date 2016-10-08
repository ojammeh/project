class ItController < ApplicationController

	def all_ips
		@ips = Ip.all
	end

	def new_it_request

		@request = ItRequest.new(:item_category => params[:item_category], :quantity => params[:quantity], :description => params[:description], :name => params[:name], :department => session[:department], :reason => params[:reason], :user =>session[:fullname], :status => 0)
		
		if(@request.save==false)
			flash[:error] = "ERROR!! Cannot create request"
			redirect_to it_new_request_path
		end
			@newitrequest = "<b>New IT Request Launched</b> <br/><br/> Launched by:  '#{session[:fullname]}' <br/> Department: '#{session[:department]}' <br/> Requested By: '#{params[:name]}' <br/> Item Category: '#{params[:item_category]}' <br/> Item Description: '#{params[:description]}' <br/> Quantity: '#{params[:quantity]}' <br/> Reason: '#{params[:reason]}' "
			ItDeliveryMailer.new_it_requesting(@newitrequest).deliver
		
		render :layout => "receipt"
	end

	def pending_requests
		@pending = ItRequest.where(status: 0)
	end

	def deliver_request
		@delivery = ItRequest.find_by_id(params[:id])
		@delivery.update_attributes(:status => 1, :delivered_by => session[:fullname])
		@name = @delivery.user
		@department = @delivery.department
		@requested_by = @delivery.name
		@category =  @delivery.item_category
		@description = @delivery.description
		@quantity = @delivery.quantity
		@reason = @delivery.reason
		@delivered_by = @delivery.delivered_by
		@requested_on = @delivery.created_at.to_date
		@delivered_on = @delivery.updated_at.to_date
		ItDeliveryMailer.it_delivery(@name,@department,@requested_by,@category,@description,@quantity,@reason,@delivered_by,@requested_on,@delivered_on).deliver

		render :layout => "receipt"
	end

end
