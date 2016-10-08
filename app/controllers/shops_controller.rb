class ShopsController < ApplicationController

	protect_from_forgery :except =>[:show, :create, :destroy_multiple]
	def create
			@shop = Shop.new(:msisdn => params[:msisdn], :name => params[:name], :area => params[:area])
			if @shop.save

			flash[:success] = "Data Successfully Saved"
			redirect_to :action => 'index'	
		else
			flash[:danger] = " This Number Already Exist"
			render 'index'
		end
	end

	def show
		@shops = Shop.order('msisdn')
	end
	def edit
		@shop = Shop.find(params[:id])
	end
	def update
		@shop = Shop.find(params[:id])
		if @shop.update_attributes(update_params)
			flash[:success] = "Data Updated"
			redirect_to shops_show_path
		else
			render 'edit'
		end
	end 
	def destroy_data
		shop = Shop.find(params[:id])
		shop.destroy

		flash[:success] = "Data Deleted"
		redirect_to shops_show_path
		
	end

	def destroy_multiple

		params[:id].each do |id|
  		@deletes = Shop.find(id.to_i)

  		@deletes.destroy 

		end
		flash[:success] = "Number Deleted"
		redirect_to shops_show_path
	end

	private
	def update_params
			params.require(:shop).permit(:msisdn, :name, :area)
			
	end
	
end
