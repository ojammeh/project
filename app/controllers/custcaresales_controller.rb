class CustcaresalesController < ApplicationController
protect_from_forgery :except => [:add_item, :stock_out, :stock_out_select, :add_stock, :add_stock_select, :bank_money, :bank, :damaged]

	def add_item
		Item.new(:name => params[:item], :price => params[:price], :user => params[:username]).save
		redirect_to custcaresales_add_item_select_path and return
	end

	def list_items
		if session[:username] == 'atarawally' or session[:username] == 'mtrinn' or session[:username] == 'amcamara'
			@items = Item.all
		else
			@items = Item.where(user: session[:fullname])
		end
	end

	def list_transactions
		if params[:search_trans]
			date1 = params[:year1].to_s + params[:month1].to_s + params[:day1].to_s
			date2 = params[:year2].to_s + params[:month2].to_s + params[:day2].to_s
			if session[:username] == 'atarawally' or session[:username] == 'mtrinn' or session[:username] == 'amcamara'
				@transactions = Stock.where('(created_at BETWEEN ? AND ?) AND trans_type=?', date1, date2,'Out').order("created_at")
			else
				@transactions = Stock.where('(created_at BETWEEN ? AND ?) AND trans_type=? AND user=?',date1, date2,'Out',session[:fullname]).order("created_at")
			end
		else
			if session[:username] == 'atarawally' or session[:username] == 'mtrinn' or session[:username] == 'amcamara'
				@transactions = Stock.where(trans_type: "Out")
			else
				@transactions = Stock.where(:trans_type => "Out" , :user => session[:fullname])
			end
		end
	end

	def stock_in_list
		if params[:search_trans]
			date1 = params[:year1].to_s + params[:month1].to_s + params[:day1].to_s
			date2 = params[:year2].to_s + params[:month2].to_s + params[:day2].to_s

			if session[:username] == 'atarawally' or session[:username] == 'mtrinn' or session[:username] == 'amcamara'
				@transactions = Stock.where('(created_at BETWEEN ? AND ?) AND trans_type=?', date1, date2,'In').order("created_at")
			else
				@transactions = Stock.where('(created_at BETWEEN ? AND ?) AND trans_type=? AND user=?',date1, date2,'In',session[:fullname]).order("created_at")
			end
		else
			if session[:username] == 'atarawally' or session[:username] == 'mtrinn' or session[:username] == 'amcamara'
				@transactions = Stock.where(trans_type: "In")
			else
				@transactions = Stock.where(:trans_type => "In", :user => session[:fullname])
			end
		end
	end

	def damaged_list
		if params[:search_trans]
			date1 = params[:year1].to_s + params[:month1].to_s + params[:day1].to_s
			date2 = params[:year2].to_s + params[:month2].to_s + params[:day2].to_s

			if session[:username] == 'atarawally' or session[:username] == 'mtrinn' or session[:username] == 'amcamara'
				@transactions = Stock.where('(created_at BETWEEN ? AND ?) AND trans_type=?', date1, date2,'Damaged').order("created_at")
			else
				@transactions = Stock.where('(created_at BETWEEN ? AND ?) AND trans_type=? AND user=?',date1, date2,'Damaged',session[:fullname]).order("created_at")
			end
		else
			if session[:username] == 'atarawally' or session[:username] == 'mtrinn' or session[:username] == 'amcamara'
				@transactions = Stock.where(trans_type: "Damaged")
			else
				@transactions = Stock.where(:trans_type => "Damaged", :user => session[:fullname])
			end
		end
	end

	def delete_item

	end

	def add_stock_select
		@items = Item.select(:name).distinct
	end

	def stock_out_select
		@items = Item.where(user: session[:fullname])
	end

	def damaged_select
		@items = Item.select(:name).distinct
	end

	def bank_money
		@items = Item.select(:name).distinct
	end

	def list_banked
		if params[:search_trans]
			date1 = params[:year1].to_s + params[:month1].to_s + params[:day1].to_s
			date2 = params[:year2].to_s + params[:month2].to_s + params[:day2].to_s
			if session[:username] == 'atarawally' or session[:username] == 'mtrinn' or session[:username] == 'amcamara'
				@transactions = Stock.where('(created_at BETWEEN ? AND ?) AND trans_type=?', date1, date2,'Bank').order("created_at")
			else
				@transactions = Stock.where('(created_at BETWEEN ? AND ?) AND trans_type=? AND user=?',date1, date2,'Bank',session[:fullname]).order("created_at")
			end
		else
			if session[:username] == 'atarawally' or session[:username] == 'mtrinn' or session[:username] == 'amcamara'
				@transactions = Stock.where(trans_type: "Bank")
			else
				@transactions = Stock.where(:trans_type => "Bank", :user => session[:fullname])
			end
		end
	end

	def bank
		item = Item.where(:name => params[:item], :user => params[:username]).first
		balance = item.cash_in_hand - params[:amount].to_f
		item.update_attributes(:cash_in_hand => balance)
		Stock.new(:user => params[:username], :item =>params[:item], :trans_type => "Bank", :banked_amount => params[:amount].to_f, :cash_in_hand => balance).save
		flash[:success] = "Transaction Successfull"
		redirect_to custcaresales_bank_money_path
	end

	def add_stock
		item = Item.where(:name => params[:item], :user => params[:username]).first
		price = item.price
		total = params[:amount].to_i * price
		item_balance = item.item_balance + params[:amount].to_i
		money_value = item.money_value + total
		item.update_attributes(:item_balance => item_balance, :money_value => money_value)

		Stock.new(:user => params[:username], :item =>params[:item], :price => price, :cash_in_hand => item.cash_in_hand, :trans_type => "In", :amount => params[:amount], :item_balance => item_balance, :total_money => total).save

		flash[:success] = "Transaction Successfull"
		redirect_to custcaresales_add_stock_select_path
	end

	def stock_out
		date = params[:year1].to_s + params[:month1].to_s + params[:day1].to_s
		item = Item.where(:name => params[:item], :user => session[:fullname]).first
		price = item.price
		total = params[:amount].to_i * price
		item_balance = item.item_balance - params[:amount].to_i
		money_value = item.money_value - total
		cash_in_hand = item.cash_in_hand + total
		item.update_attributes(:item_balance => item_balance, :money_value => money_value, :cash_in_hand => cash_in_hand)

		Stock.new(:user => session[:fullname], :item =>params[:item], :price => price, :cash_in_hand => cash_in_hand, :trans_type => "Out", :amount => params[:amount], :item_balance => item_balance, :total_money => total, :created_at => date).save

		flash[:success] = "Transaction Successfull"
		redirect_to custcaresales_stock_out_select_path
	end

	def damaged
		item = Item.where(:name => params[:item], :user => params[:username]).first
		price = item.price
		total = params[:amount].to_i * price
		item_balance = item.item_balance - params[:amount].to_i
		money_value = item.money_value - total
		cash_in_hand = item.cash_in_hand
		item.update_attributes(:item_balance => item_balance, :money_value => money_value)

		Stock.new(:user => session[:fullname], :item =>params[:item], :price => price, :cash_in_hand => cash_in_hand, :trans_type => "Damaged", :amount => params[:amount], :item_balance => item_balance, :total_money => total).save

		flash[:success] = "Transaction Successfull"
		redirect_to custcaresales_stock_out_select_path
	end
end
