class SoapController < ApplicationController

  def account_details
  	client = Savon.client(wsdl: "http://192.168.0.232:8080/axis2/services/WebService?wsdl")
  	message = { :operatorName.to_s => 'AUP', :MSISDN.to_s => params[:msisdn] }
  	response = client.call(:get_account_details, message: message).xml

  	Nokogiri::HTML(response).root.children.each do |node|
		@COS = node.at_css('cos').content
		@accountType = node.at_css('accounttype').content
		@balance = node.at_css('balance').content
		@cutoffDate = node.at_css('cutoffdate').content
		@deleteDate = node.at_css('deletedate').content
		@expiryDate = node.at_css('expirydate').content
		@firstUse = node.at_css('firstuse').content
		@freeData = node.at_css('freedata').content
		@freeDataEndDate = node.at_css('freedataenddate').content
		@freeMoney = node.at_css('freemoney').content
		@freeMoneyEndDate = node.at_css('freemoneyenddate').content
		@freeSMS = node.at_css('freesms').content
		@freeSMSEndDate = node.at_css('freesmsenddate').content
		@freeTime = node.at_css('freetime').content
		@freeTimeEndDate = node.at_css('freetimeenddate').content
		@homezoneChangeDate = node.at_css('homezonechangedate').content
		@homezoneName = node.at_css('homezonename').content
		@languageName = node.at_css('languagename').content
		@lifeCycleState = node.at_css('lifecyclestate').content
		@pin = node.at_css('pin').content
		@previousMSISDN = node.at_css('previousmsisdn').content
		@resultCode = node.at_css('resultcode').content
		@resultText = node.at_css('resulttext').content
		@status = node.at_css('status').content
		@stdCharge = node.at_css('stdcharge').content
		@stdChargeDate = node.at_css('stdchargedate').content
	end
	#if response.success?
  end
end
