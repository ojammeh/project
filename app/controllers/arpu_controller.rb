class ArpuController < ApplicationController

	def index 
		if(session[:username] == "arpu1")
			@numbers = Arpu.where('status is ? and user_list =?',nil,1).order("id").page(params[:page]).per(500)
		elsif(session[:username] == "arpu2")
			@numbers = Arpu.where('status is ? and user_list =?',nil,2).order("id").page(params[:page]).per(500)
		end	
	end

	def update
		@msisdn = "220"+params[:msisdn]
		@number = Arpu.find_by_id(params[:id])
		if(params[:data].nil? and params[:call].nil? and params[:none].nil?)
			flash[:processed] = 'ERROR!'
		elsif(params[:data] and params[:call] and params[:none])
			flash[:processed] = 'ERROR!'
		elsif(params[:data] and params[:none])
			flash[:processed] = 'ERROR!'
		elsif(params[:call] and params[:none])
			flash[:processed] = 'ERROR!'
		elsif @number.status != nil
			flash[:processed] = 'Already Processed by other user!'
		else
	  		if(params[:data] and params[:call].nil?)
	  			Token.find_by_sql("EXEC uspAddPromotionalTokens '#{@msisdn}',1000000,'High ARPU','Live'")
	  			@number.update_attributes(:updated_at => Time.now, :data => params[:data], :call => params[:call], :status => 1, :agent => session[:username])
	  		elsif(params[:call] and params[:data].nil?)
	  			Linkedserver.find_by_sql("EXEC AddFreeTime '#{params[:msisdn]}','High ARPU',3600")
	  			@number.update_attributes(:updated_at => Time.now, :data => params[:data], :call => params[:call], :status => 1, :agent => session[:username])
	  		elsif(params[:data] and params[:call])
	  			Token.find_by_sql("EXEC uspAddPromotionalTokens '#{@msisdn}',1000000,'High ARPU','Live'")
	  			Linkedserver.find_by_sql("EXEC AddFreeTime '#{params[:msisdn]}','High ARPU',3600")
	  			@number.update_attributes(:updated_at => Time.now, :data => params[:data], :call => params[:call], :status => 1, :agent => session[:username])
	  		elsif(params[:none] and params[:data].nil? and params[:call].nil?)
	  			@number.update_attributes(:updated_at => Time.now, :status => 1, :nothing => params[:none], :agent => session[:username])
	  		end
	  		flash[:processed] = 'Successful'
	  	end
  		redirect_to arpu_index_path

	end
end
