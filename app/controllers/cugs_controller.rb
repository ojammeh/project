class CugsController < ApplicationController
	protect_from_forgery :except =>[:create, :addnumber, :search, :destroy_multiple]

	def index
		@cugs = Cug.where(deleted: 0).order("name")#.paginate(:page => params[:page])
	end

	def create
		@createcug = Cug.new(:name => params[:name], :monthly_charge => params[:monthly_charge], :phone => params[:phone],
							:comments => params[:comments], :date_created => Time.now, :deleted => 0)
		if @createcug.save
			Cuglog.new(:number => params[:name], :action => 'New Cug Added', :created_at =>Time.now, :ip =>request.remote_ip,  :user => session[:username]).save
			@created =Time.now.to_s
			@name =@createcug.name
			@charge =@createcug.monthly_charge
			@comments = @createcug.comments

			@cug ="CUG Name = "  + @name, " ---- Monthly Charge = " +@charge, " --- Comments = "+ @comments, " --- Created Time = "+@created
			CugMailer.new_cug(@cug).deliver

			flash[:success] = "CUG Created"
			redirect_to :action => 'index'
		else
			flash[:danger] = "CUG not created please check and confirm that all your fields are correct"
			render 'home'
		end
	end

	def search
		numbers = Number.find_by_sql("select * from numbers where number LIKE '%#{params[:numbers]}%'").first
		if !numbers.blank?
			cugname = Cug.find_by_id(numbers.cug_id)
			@cug_name = cugname.name
			@number = numbers.number
			@date = numbers.created_at
			@show = "numbers"
		else
			cugnames = Cug.where(Cug.arel_table[:name].matches("%#{params[:numbers]}%")).last unless Cug.blank?
			if !cugnames.blank?
				@view = "names"
				@cug_id = cugnames.id
				@cug_name = cugnames.name
				@cug_month = cugnames.monthly_charge
				@cug_phone = cugnames.phone
				@cug_comment = cugnames.comments
				@cug_date = cugnames.date_created
			else
				flash[:danger] = "The keyword does not exist"
				redirect_to :action => 'index'
			end
		end
	end

	def show
		@cugdetails = Cug.find_by_id(params[:id])
		@numbers = Number.where(cug_id: @cugdetails)
		@cug_name = @cugdetails.name
	end
    def addnumber
  		cugs = params[:cug]
  		prepaid = []
		postpaid = []
  		cugs.each do |c|
		    @number = Number.new(:cug_id => params[:id])
		    nums = c[1]
		    # numbers_to_mail.push(nums)
		    @number.number = nums
		    @newnum = @number.number
		    @postpaid = Postpaid.where(msisdn: "220"+@newnum)
		    @cug = Cug.find_by_id(params[:id])
		    @cug.numbers << @number
		    if (@number.save)
		      	@numz = Number.find_by_id(@number)
		      	if @postpaid.blank?
			        @numz.update_attributes(:type_id => 1)
			        prepaid.push(nums)
		      	else
			        @numz.update_attributes(:type_id => 2)
			        postpaid.push(nums)
		      	end
		      	@cugname = @cug.name
			  	Cuglog.new(:number => @newnum, :action => 'New Number added to CUG', :created_at =>Time.now, :ip => request.remote_ip, :user => session[:username]).save
			  	@prepaid_num = prepaid
	  			@postpaid_num = postpaid

				flash[:success] = "Successfully added number to CUG"
			else
				flash[:danger] = "Number Already Exist in a CUG"
			end
	   	end
    	haspostpaid = Number.where(type_id: 2).where(cug_id: @cug)
    	if !haspostpaid.blank?
    		if @number.save
		   		CugMailer.postpaid_mailer(@postpaid_num,@cugname,@prepaid_num).deliver
		   	end
		end
		if @number.save
    		CugMailer.prepaid_mailer(@prepaid_num,@cugname,@postpaid_num).deliver
    	end
  		redirect_to :action => 'show', :id => params[:id]
	end

	def destroy_number
		delete = Number.find(params[:id])
		cugID = delete.cug_id
		cug = delete.number
		created = delete.created_at
		cugName = Cug.find_by_id(cugID).name

		Cuglog.new(:number => cug, :action => 'Number Deleted from CUG', :created_at =>Time.now, :ip => request.remote_ip, :user => session[:username]).save
		Deletednumber.new(:number =>cug, :comments =>cugName, :cug_id =>cugID, :deleted =>1, :created_at => Time.now, :date_deleted => Time.now).save
		delete.destroy

		numtype = delete.type_id
		if numtype == 1
			numberis = "Prepaid"
		elsif numtype == 2
			numberis ="Postpaid"
		end
		if numtype == 1
		delnum = delete.cug.name + "  "+ delete.number+" "+numberis
		CugMailer.delete_number_postpaid(delnum).deliver
		if numtype == 2
			CugMailer.delete_number(delnum).deliver
		end
		end
		flash[:success] = "Number Deleted"
		redirect_to (:back)
	end

	def destroy_multiple

  		del = params[:nums]
		# all_numbers = []
			prepaid = []
			postpaid = []

			del.each do |num|
			

  		@deletes = Number.find(params[:id])
  		@cugID = @deletes.cug_id
			@cug = @deletes.number
		# created = delete.created_at
			@cugName = Cug.find_by_id(@cugID).name
  		@deletes = Number.find_by_number(num).destroy
  		@prepaid_num = prepaid
			@postpaid_num = postpaid

		numtype = @deletes.type_id

		if numtype == 1
			prepaid.push(num)
			# CugMailer.delete_multiple(@prepaid_num,@cugname,@postpaid_num).deliver

		elsif numtype == 2
			postpaid.push(num)
			# CugMailer.delete_multiple_postpaid(@postpaid_num,@cugname,@prepaid_num).deliver

		end
		end
		@cugname = @deletes.cug.name
		if @prepaid_num = prepaid
			CugMailer.delete_multiple(@prepaid_num,@cugname,@postpaid_num).deliver
		end
		if @postpaid_num = postpaid
			CugMailer.delete_multiple_postpaid(@postpaid_num,@cugname,@prepaid_num).deliver
		end
		flash[:success] = "Number(s) Deleted"
		redirect_to (:back)
	end

	def destroy_cug
		delete = Cug.find_by_id(params[:id])
		delete.update_attributes(:deleted => 1, :date_deleted => Time.now)
		delnumber = Number.where(cug_id: delete)
		delnumber.each do |number|
			Deletednumber.new(:number =>number.number, :comments =>delete.name, :cug_id =>delete, :deleted =>1, :created_at => number.created_at, :date_deleted => Time.now).save
			number.destroy
		end
		delcug = delete.name
		Cuglog.new(:number => delete.name, :action => 'CUG Deleted', :created_at =>Time.now, :ip => request.remote_ip, :user => session[:username]).save
		CugMailer.delete_cug(delcug).deliver
		redirect_to :action => 'index'
	end

	def edit
		@cug = Cug.find(params[:id])
	end

	def update
		@cug = Cug.find(params[:id])
		if @cug.update_attributes(update_params)
			flash[:success] = "Cug Updated"
			redirect_to cugs_index_path
		else
			render 'edit'
		end
	end

	private
	def update_params
		params.require(:cug).permit(:name, :monthly_charge, :phone,
		:comments)
	end
end
