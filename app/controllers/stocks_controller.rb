class StocksController < ApplicationController
	protect_from_forgery :except =>[:create, :new_item, :update_stock, :add_cat]

	def home
		@cats = Category.all
	end
	def stock_out
		@cats = Category.all
		
	end
	def new_item
		Itemz.new(:add_date => params[:date], :item_name => params[:item_name], :part_no => params[:part_number], :description => params[:description], :category => params[:category], 
		:initial_amount => params[:initial_amount], :item_in => params[:initial_amount]).save#, :site => params[:site],
			# :item_in => params[:in], :initial_amount => params[:in], :item_out => params[:out], :balance => (params[:in].to_i - params[:out].to_i)).save

		redirect_to :controller => 'stocks', :action => 'all_stock'
		
	end

	def all_stock
		@itemz = Itemz.all 
		
	end
	def add_cat
		@cats = Category.all
		Category.new(:category_name => params[:category]).save

		flash[:success] = "Category Successfully Added"
		redirect_to (:back)
	end
	def edit
		@edititems = Itemz.find(params[:id])
	end
	def update_stock
		@items = Itemz.find(params[:id])
		if @items.update_attributes(:id => params[:id], :add_date => params[:date], :part_no => params[:part_number], 
			:description => params[:description], :site => params[:site],
			:item_in => params[:in], :item_out => params[:out].to_i + params[:outs].to_i, 
			:balance => (params[:outs].to_i.abs + params[:out].to_i.abs - params[:in].to_i.abs).abs)

		flash[:success] = "Item Out"
		redirect_to :controller => 'stocks', :action => 'all_stock'
	else
		flash[:danger] = "error"
		redirect_to :controller => 'stocks', :action => 'new_item'
	end
	end
	def destroy
		Itemz.find(params[:id]).destroy
		redirect_to :controller => 'stocks', :action => 'all_stock'
		
	end
	# def update
	# 	@items = Item.find(params[:id])
	# 	if @items.update_attributes(update_params)
	# 		flash[:success] = "Stock Updated"
	# 		redirect_to :controller => 'stocks', :action => 'all_stock'
	# 	else
	# 		render 'edit'
	# 	end
	# end 
	
	# private
	# def update_params
	# 		params.require(:item).permit(:add_date, :part_no,
	# 		:description, :item_in, :item_out, :balance)
			
	# end
end
