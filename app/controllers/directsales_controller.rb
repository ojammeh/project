class DirectsalesController < ApplicationController
	protect_from_forgery :except => [:insert, :update_team, :delete_team, :create_team, :edit_team]

def list
	@list = DirectSale.all.order("id").page(params[:page]).per(100)
end

def input
	@teams = DirectSale.find_by_sql("SELECT * FROM direct_teams")
end

def create_team
	DirectTeam.new(:team_id => params[:teamid], :team_leader => params[:tleader], :date => Time.now).save
	redirect_to directsales_add_team_path
end

def list_teams
	@list = DirectSale.find_by_sql("SELECT * FROM direct_teams")
end

def edit_team
	@team = DirectTeam.find_by_id(params[:id])
end

def delete_team
	team = DirectTeam.find_by_id(params[:id])
	team.destroy
	redirect_to directsales_list_teams_path
end

def update_team
	team = DirectTeam.find_by_id(params[:id])
	team.update_attributes(:team_id => params[:teamid], :team_leader => params[:tleader], :updated_at => Time.now,
		:updated_by => session[:username])
	redirect_to directsales_list_teams_path
end

def insert
	client_ip = request.remote_ip
	user = session[:fullname]
	now =Time.now
	
	day = params[:day].to_s
	month = params[:month].to_s
	year = params[:year].to_s
	date = year+month+day
	ssno = '%'+params[:ssno]
	esno = '%'+params[:esno]

	simsicheck = KhavasControl.find_by_sql("SELECT * FROM MSIN_Inventory where ICCD like '#{ssno}'")
	simsicheck.each do |ssims|
		@simsi = ssims.MSIN
	end

	eimsicheck = KhavasControl.find_by_sql("SELECT * FROM MSIN_Inventory where ICCD like '#{esno}'")
	eimsicheck.each do |esims|
		@eimsi = esims.MSIN
	end
	simsi = @simsi
	eimsi = @eimsi
	
	#simsiC = params[:ssno][1..2].to_i
	#simsiA = (simsiC - 1).to_s
	#simsiB = (params[:ssno][3..7]).to_s
	#simsi = "990"+simsiA+simsiB
	
	#eimsiC = params[:esno][1..2].to_i
	#eimsiA = (eimsiC - 1).to_s
	#eimsiB = params[:esno][3..7]
	#eimsi = "990"+eimsiA+eimsiB
	
	simquantity2 = params[:esno].to_i
	simquantity1 = params[:ssno].to_i
	simquantity3 =(simquantity2 - simquantity1)+1
	simquantity =simquantity3.to_s
	
	if(params[:quantity] == simquantity)
		team = DirectTeam.find_by_team_id(params[:teamid])
		input = DirectSale.new(:date => date, :Dealer_Code => params[:dcode], :Dealer_Name => params[:dname], :Team_ID => params[:teamid], :Team_T_No => params[:teamtno], :Destination => params[:destination], :Team_Leader => team.team_leader, :SIM_Quantity => params[:quantity], :Start_Serial_No => params[:ssno], :End_Serial_No => params[:esno], :Start_IMSI_Range => simsi, :End_IMSI_Range => eimsi)
	
		if (input.save)
			flash[:success] ="Details successfully saved"
			redirect_to directsales_input_path
			#Directlogs.new(:user =>@user, :ip => @client_ip, :created_at =>@now, :action =>"new entry", :date => @date, :Dealer_Code => params[:dcode], :Dealer_Name => params[:dname], :Team_ID => params[:teamid], :Team_T_No => params[:teamtno], :Destination => params[:destination], :Team_Leader => params[:tleader], :SIM_Quantity => simquantity, :Start_Serial_No => params[:ssno], :End_Serial_No => params[:esno], :Start_IMSI_Range => @simsi, :End_IMSI_Range => @eimsi).save
		end
	else
		flash[:error] ="Serial Calculation do not match SIM Quantity. Please check serials."
		redirect_to directsales_input_path
	end
	
end

def delete
	@client_ip = request.remote_ip
	#@user = @session['user'].login
	@now = Time.now
	
	@del = DirectSale.find_by_id(params[:id])
	@del.destroy
	#Directlogs.new(:user => @user, :created_at => @now, :ip => @client_ip, :action => "delete",:date => @date, :Dealer_Code => params[:dcode], :Dealer_Name => params[:dname], :Team_ID => params[:teamid], :Team_T_No => params[:teamtno], :Destination => params[:destination], :Team_Leader => params[:tleader], :SIM_Quantity => params[:squantity], :Start_Serial_No => params[:ssno], :End_Serial_No => params[:esno], :Start_IMSI_Range => params[:sirange], :End_IMSI_Range => params[:eirange]).save
	
	flash[:del] = "Record Successfully deleted"
	redirect_to directsales_list_path
end
end
