class BanksController < ApplicationController
	# require 'humanize'
	# require 'numbers_in_words'
	require 'date'
	protect_from_forgery :except =>[:create, :suppliers_bank, :supplier_account, :africell_bank, :account_type, :account_number, :b_ban, :signatories, :update_bank, :update_supplier, :print_log]

	# def index
		
	# end
	def create
		@supplier = Supplier.new(:name => params[:name], :address => params[:address])
		if @supplier.save
			flash[:success] = "Supplier Successfully Added"
			redirect_to :controller => "banks", :action => "supplier_bank", :id => @supplier.id
		else
			render 'index'
		end
	end

	def supplier_bank
		@supplier = Supplier.all
		@suppliers = Supplier.find_by_id(params[:id])
	end

	def suppliers_bank
		@supplierBank = SupplierBank.new(:supplier_id => params[:supplier_id], :bank_name => params[:bank_name], :bank_address => params[:bank_address], :swift_code => params[:swift_code])
		if @supplierBank.save
			flash[:success] = "Supplier Bank Successfully Added"
			redirect_to :controller => "banks", :action => "supplier_accounts", :id => @supplierBank.id
		else
			render 'index'
		end
	end

	def supplier_accounts
		@supplier = Supplier.all
		@supplierBank = SupplierBank.find_by_id(params[:id])
		@supplier_id = SupplierBank.find_by_id(params[:id])
		@supplierID = SupplierBank.all
	end

	def supplier_account
		@supplierAccount = SupplierAccountNumber.new(:supplier_id => params[:supplier_id], :supplier_bank_id => params[:supplier_bank_id], :account_number => params[:account_number], :account_type => params[:account_type])
		if @supplierAccount.save
			flash[:success] = "Supplier Account Successfully Added"
			redirect_to :controller => "banks", :action => "list_supplier"
		else
			render 'index'
		end
	end

	def africell_bank
		@afriBanks = AfricellBank.new(:bank_name => params[:bank_name], :bank_address => params[:bank_address], :addressee => params[:addressee], :designation => params[:designation])
		if @afriBanks.save
			flash[:success] = "Bank Successfully Added"
			# @afriBanks = AfricellBank.find_by_id(params[:id])
			redirect_to :controller => "banks", :action => "account_types", :id => @afriBanks.id
		else	
			render 'index'
		end
	end

	def account_types
		@afriBank = AfricellBank.all
		@afriBanks = AfricellBank.find_by_id(params[:id])
		@actype = TypeOfAccount.all
		
	end

	def account_type
		@afriBanks = AfricellBank.find_by_id(params[:id])
		@accType = AccountType.new(:africell_bank_id => params[:africell_bank_id], :account_type => params[:account_type])
		if @accType.save
			flash[:success] = "Account Type Successfully Added"
			redirect_to :controller => "banks", :action => 'account_numbers', :id => @accType.id	
		else
			render 'index'
		end
	end

	def account_numbers
		@accType = AccountType.all
		@accTypes = AccountType.find_by_id(params[:id])
		@afriBank = AfricellBank.all	
		@afriBanks = AfricellBank.find_by_id(params[:id])
	end

	def account_number
		
		@accNumber = AccountNumber.new(:account_type_id => params[:account_type_id], :account_number => params[:account_number], :africell_bank_id => params[:africell_bank_id])
		if @accNumber.save
			flash[:success] = "Account Number Successfully Added"
			redirect_to :controller => "banks", :action => 'b_bans', :id => @accNumber.id
		else
			render 'index'
		end
	end

	def b_bans
		@accNo = AccountNumber.find_by_id(params[:id])
		@accType = AccountType.all
		@accNos = AccountType.find_by_id(@accNo)
		# @acType = AccountNumber.where(account_type_id: @accNos)
	end

	def b_ban
		@Bban = BBan.new(:account_type_id => params[:account_type_id], :africell_bank_id => params[:africell_bank_id], :b_ban_number => params[:b_ban_number])
		if @Bban.save
			flash[:success] = "Bban Successfully Added"
			redirect_to :controller => "banks", :action => "list_bank"
		else
			render 'index'
		end
	end

	def signatories
		@signatory = Signatory.new(:name => params[:name], :designation => params[:designation])
		if @signatory.save
			flash[:success] = "Signatory Successfully Added"
			redirect_to (:back)	
		else
			render 'index'
		end
	end

	def list_bank
		@banks = AfricellBank.order(:bank_name)
		@hum = params[:amount_numbers]
	end

	def list_supplier
		@supplier = Supplier.all
	end

	def destroy_data
		@bank = AfricellBank.find(params[:id])
		@bank.destroy
		@accType = AccountType.find_by_africell_bank_id(@bank)
		@accType.destroy
		@accNumber = AccountNumber.find_by_africell_bank_id(@bank)
		@accNumber.destroy

		flash[:success] = "Data Deleted"
		redirect_to (:back)	
	end

	def edit_bank
		@bank = AfricellBank.find(params[:id])
	end

	def update_bank
		@bank = AfricellBank.find_by_id(params[:id])
		@bank.update_attributes(:id => params[:id], :bank_name => params[:bank_name], :bank_address => params[:bank_address])

		@accType = AccountType.find_by_africell_bank_id(params[:africell_bank_id])
		@accType.update_attributes(:africell_bank_id => params[:africell_bank_id], :account_type => params[:account_type])

		@accNumber = AccountNumber.find_by_africell_bank_id(params[:africell_bank_id])
		@accNumber.update_attributes(:africell_bank_id => params[:africell_bank_id], :account_number => params[:account_number])

		redirect_to (:back)	
	end

	def destroy_supplier
		@supplier = Supplier.find(params[:id])
		@supplier.destroy
		@supBank = SupplierBank.find_by_supplier_id(@supplier)
		@supBank.destroy
		@supAccount = SupplierAccountNumber.find_by_supplier_id(@supplier)
		@supAccount.destroy

		flash[:success] = "Data Deleted"
		redirect_to (:back)	
	end

	def edit_supplier
		@supplier = Supplier.find(params[:id])
	end

	def update_supplier
		@supplier = Supplier.find_by_id(params[:id])
		@supplier.update_attributes(:id => params[:id], :name => params[:name], :address => params[:address])

		@supBank = SupplierBank.find_by_supplier_id(params[:supplier_id])
		@supBank.update_attributes(:supplier_id => params[:supplier_id], :bank_name => params[:bank_name], :bank_address => params[:bank_address],
			:swift_code => params[:swift_code])
		@accNumber = SupplierAccountNumber.find_by_supplier_id(params[:supplier_id])
		@accNumber.update_attributes(:supplier_id => params[:supplier_id], :account_number => params[:account_number], :account_type => params[:account_type])

		redirect_to (:back)	
	end

	def debit_account
		@debit = AfricellBank.find(params[:id])
		@deb   = AccountType.find_by_africell_bank_id(@debit)
		@acc   = AccountNumber.find_by_africell_bank_id(@debit)
		@bban  = BBan.find_by_africell_bank_id(@debit)

		@supplier = Supplier.all
	end

	def bank
		respond_to do | format |
	        format.js
	        format.html
	        @supplier = Supplier.all
	        @banks = AfricellBank.all
	        @bank_id = params[:id]
	        
		end
	end
	def publish
		@afri_bank_id = AfricellBank.find_by_id(params[:bank_id])
		@supplier_id = Supplier.find_by_id(params[:sup_id])
		@designation = Signatory.all

		@day = Date.today.to_s[5..6]
		@month = Date.today.to_s[8..9]

		@reference = @month+"/"+@day+"/"

		@ref = Reference.new(:date => Date.today).save
		@refs = Reference.maximum("id")

		@amount = params[:huminize]
		# @conv = PrintLog.find_by_sql("SELECT id, amount_numbers FROM `print_logs` WHERE id=( SELECT max(id) FROM `print_logs` )")
		# @conv = params[:amount_numbers => nil]

		# @conv = PrintLog.find_by_sql("SELECT amount_numbers FROM `print_logs` WHERE id=( SELECT max(id) FROM `print_logs` )")

		# 	@conv.each do |con|
		# 			@cons = con.amount_numbers.humanize
	 # 			end

		render :layout => "bank"
	end

	def print_log
		@conv = params[:amount_numbers] 
		@printlog = PrintLog.new(:bank_name => params[:bank_name],  :bank_address => params[:bank_address], :ref_no => params[:ref_no], :account_type => params[:account_type], :account_number => params[:account_number],
			:b_ban_number => params[:b_ban_number],:amount_numbers => params[:amount_numbers],:amount_words => params[:amount_words], :supplier_name => params[:supplier_name], 
			:supplier_bank_name => params[:supplier_bank_name], :supplier_account_number => params[:supplier_account_number], :supplier_bank_address => params[:supplier_bank_address], 
			:supplier_swift_code => params[:supplier_swift_code], :name_first_designation => params[:name_1], :name_second_designation => params[:name_2], :name_third_designation => params[:name_3],
			 :first_designation => params[:first_designation], :second_designation => params[:second_designation], :third_designation => params[:third_designation], :ip_address => request.remote_ip, :printed_by => session[:username] )#.save
		if @printlog.save
			# @conv = Supplier.find_by_id(params[:sup_id])
			# @conv = PrintLog.find_by_sql("SELECT amount_numbers FROM `print_logs` WHERE id=( SELECT max(id) FROM `print_logs` )")

			# @conv.each do |con|
			# 		@cons = con.amount_numbers
	 	# 		end
		 	redirect_to (:back)
		else
			flash[:danger] = "Error Occured"
		end
	end
end	