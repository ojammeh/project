    # Sockets are in standard library
require 'socket' 

class Hlr
	
       s = TCPSocket
       pgwDB = Pgw

	def initialise
		s = TCPSocket.new
		pgwDB = Pgw.new
	end


 	
    

	  # this method will execute any hlr command as per database specification
       def execute(aCommand,aPGW,aUser,aPassword,para1,para2,para3,para4,para5,para6,para7,para8,para9,para10)

		result = ""
 		hostname = aPGW
 		user = aUser
 		password = aPassword
 		msisdn = para1
		port = 7776
		command = aCommand

		commandString = buildCommand(aCommand,para1,para2,para3,para4,para5,para6,para7,para8,para9,para10)
		puts 'about to open tcp connection.....'
		s = TCPSocket.open(hostname, port)
		puts 'connection opened'
		s.write("LGI:OPNAME=\"#{user}\", PWD=\"#{password}\";")

		puts 'logged in!'
		stream = true

		while stream
	 		line = s.gets
 			 puts line.chop 
 	 		if (line[/END/])
 	 			stream = false
 	 	  		#s.close
 			end 
 		end

 		s.write(commandString)
 		s.write("LGO:;")



		stream = true

		while stream
			 line = s.gets 
	 		result = result+line
 	 		#puts line.chop 
 	 		if (line[/END/])
 	 			stream = false
 	 			s.close 
 	 			puts 'closed connection' 
 			end 
 		end

 		return result



       end
 	


def login

	puts 'about to open tcp connection.....'
		s = TCPSocket.open(hostname, port)
		puts 'connection opened'
		s.write("LGI:OPNAME=\"#{user}\", PWD=\"#{password}\";")

		puts 'logged in!'


		stream = true

		while stream
	 		line = s.gets
 			 puts line.chop 
 	 		if (line[/END/])
 	 			stream = false
 	 	  		s.close 
 	 	  		puts 'closed connection'
 			end 
 		end
 	end

# this method will find if such a command exists in the database 
#of commands and attempt to build it together with neccessary parameters


def buildCommand(akeyword, para1,para2,para3,para4,para5,para6,para7,para8,para9,para10)


	keyword = akeyword
	commandString = "" 
                 
	result = Pgw.where(command: keyword).first
		if !(result.blank?)  # the command exists in the database
			commandString = commandString + result.command_actual
			if (result.parameters == 1) # the command only has one argument
				commandString = commandString + result.para_1 + "\""+ para1  +  "\""
			end

			if (result.parameters == 2) # the command two argument
				commandString = commandString  + result.para_1 + "\""+ para1  +  "\"" + "," + result.para_2 + para2
			end

			if (result.parameters == 3) # the command only has 3 arguments
				commandString = commandString  + result.para_1 + "\""+ para1  +  "\"" + "," + result.para_2 + para2 + "," + result.para_3 + para3
			end

			if (result.parameters == 4) # the command only has 3 arguments
				commandString = commandString  + result.para_1 + para1  + "," + result.para_2 + "\""+ para2  +  "\"" + "," + result.para_3 + "\"" + para3  +  "\"" + "," + result.para_4 +  para4
			end

			if (result.parameters == 6) # the command only has 6 arguments
				commandString = commandString  + result.para_1 + para1  +  "," + result.para_2 +  para2  +  "," + result.para_3 + para3 + "," + result.para_4 + "\""+ para4  +  "\"" + "," + result.para_5 + "\""+ para5  +  "\"" + "," + result.para_6 + para6
			end

			if (result.parameters == 11) # this is an exceptinal parameter
				commandString = commandString  + result.para_1 + para1  + "," + result.para_2 + "\""+ para2  +  "\"" + "," + result.para_3 + para3 + "," + result.para_4 +  para4
			end
               commandString = commandString + ";"
           end

		return commandString


end


end

command = ARGV[3] # dedicted issued HLR command

case(command)
	when "DISPLAY" then puts Hlr.new.display(ARGV[0],ARGV[1],ARGV[2],ARGV[4])
	when "DISPLAYKI" then puts Hlr.new.display(ARGV[0],ARGV[1],ARGV[2],ARGV[4])
	else puts ""#("Usage: hlr.rb <gateway>  <user>  <password> <COMMAND> <subscriber> <extra>")
	
end
