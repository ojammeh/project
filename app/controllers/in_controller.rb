class InController < ApplicationController

	def call_history
		@call_history = LivefeedCdr.find_by_sql("SELECT TOP 80 * FROM [dbo].[cdrs] WHERE accnum ='#{params[:msisdn]}' ORDER BY CAST(chdate as VARCHAR)+CAST(chtime as VARCHAR) DESC")
		#@call_history = LivefeedCdr.where(accnum: params[:msisdn]).order('chdate desc').limit(50)
	end

	def account_history
		@account_history = LivefeedSsr.find_by_sql("SELECT TOP 80 * FROM [dbo].[vw_ssrs] WHERE accnum ='#{params[:msisdn]}' ORDER BY time DESC")
		#@account_history = LivefeedSsr.where(accnum: params[:msisdn]).order('time desc').limit(50)
	end
end
