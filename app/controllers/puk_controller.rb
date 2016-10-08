class PukController < ApplicationController

	def search_result
		session[:msisdn] = params[:number]
		if(params[:number].length == 8)
			@numtype = "imsi"
			iccid = '8922002030'+params[:number]+'_'
			@result = Puk.find_by_sql("select PUK from Inkript where ICCID like '#{iccid}'")
			if @result.blank?
				@notfound ="PUK Not Found"
			end
		elsif(params[:number].length == 7) 
			@numtype = "msisdn"
			num = Ha.where(MSISDN: params[:number])
				num.each do |nums|
					@imsi = nums.IMSI
				end
			@result  = Puk.where(IMSI: '60702'+@imsi)
			if @result.blank?
				@notfound ="PUK Not Found"
			end
		else
			@numtype = "invalid"
		end
			UserLog.new(:user => session[:fullname], :transaction_type => "PUK", :description => "Searched For PUK", :msisdn => session[:msisdn], :ip_address =>request.remote_ip, :username => session[:username], :created_at => Time.now).save
			Custcarelog.new(:msisdn	=> session[:msisdn], :username => session[:username], :full_name => session[:fullname], :department => session[:department], :role => session[:userrole], :transaction_type => "PUK", :action_performed => "Search", :description =>"Searched PUK Number").save
	end
end
