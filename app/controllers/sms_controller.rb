class SmsController < ApplicationController
	protect_from_forgery :except => [:new]
	def new
		bnumber = "+220"+params[:bnumber]
		newsms = Sms.new(:anumber => params[:anumber], :bnumber => bnumber, :message => params[:message], :sent => 0)
		if newsms.save
			@sent = true
		else
			@sent = false
		end
	end
end
