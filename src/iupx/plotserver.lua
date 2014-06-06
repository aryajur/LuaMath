-- Plotserver.lua
-- This file is launched by iupx module to create a plotting server
-- All plotting requests go to this file once launched using LuaSocket
-- This allows user to have plots simultaneously with the lua interpreter 
-- using the standard lua interpreter
-- Milind Gupta 6/6/2014

-- SERVER SOCKET COMMANDS
-- END	- Shutdown and exit
-- RUN CODE - Execute the code in the enclosed packet

-- SOCKET COMMAND TO/FROM PARENT STRUCTURE
-- It is a Lua table with the command/Response on index 1 followed by extra arguments on following indices

-- SERVER RESPONSES
-- ACKNOWLEDGE
-- ERROR
-- SERVER FAIL - Next index has the error message
-- SERVER SUCCESS - Next index has the port number of the server where it is listening

socket = require("socket")	-- socket is used to communicate with the main program and detect when to shut down

local args = {...}		-- arguments given by parent
local parentPort 
local port

-- Function to convert a table to a string
-- Metatables not followed
-- Unless key is a number it will be taken and converted to a string
function tableToString(t)
	local rL = {cL = 1}	-- Table to track recursion into nested tables (cL = current recursion level)
	rL[rL.cL] = {}
	do
		rL[rL.cL]._f,rL[rL.cL]._s,rL[rL.cL]._var = pairs(t)
		rL[rL.cL].str = "{"
		rL[rL.cL].t = t
		while true do
			local k,v = rL[rL.cL]._f(rL[rL.cL]._s,rL[rL.cL]._var)
			rL[rL.cL]._var = k
			if not k and rL.cL == 1 then
				break
			elseif not k then
				-- go up in recursion level
				if string.sub(rL[rL.cL].str,-1,-1) == "," then
					rL[rL.cL].str = string.sub(rL[rL.cL].str,1,-2)
				end
				--print("GOING UP:     "..rL[rL.cL].str.."}")
				rL[rL.cL-1].str = rL[rL.cL-1].str..rL[rL.cL].str.."}"
				rL.cL = rL.cL - 1
				rL[rL.cL+1] = nil
				rL[rL.cL].str = rL[rL.cL].str..","
			else
				-- Handle the key and value here
				if type(k) == "number" then
					rL[rL.cL].str = rL[rL.cL].str.."["..tostring(k).."]="
				else
					rL[rL.cL].str = rL[rL.cL].str..tostring(k).."="
				end
				if type(v) == "table" then
					-- Check if this is not a recursive table
					local goDown = true
					for i = 1, rL.cL do
						if v==rL[i].t then
							-- This is recursive do not go down
							goDown = false
							break
						end
					end
					if goDown then
						-- Go deeper in recursion
						rL.cL = rL.cL + 1
						rL[rL.cL] = {}
						rL[rL.cL]._f,rL[rL.cL]._s,rL[rL.cL]._var = pairs(v)
						rL[rL.cL].str = "{"
						rL[rL.cL].t = v
						--print("GOING DOWN:",k)
					else
						rL[rL.cL].str = rL[rL.cL].str.."\""..tostring(v).."\""
						rL[rL.cL].str = rL[rL.cL].str..","
						--print(k,"=",v)
					end
				elseif type(v) == "number" then
					rL[rL.cL].str = rL[rL.cL].str..tostring(v)
					rL[rL.cL].str = rL[rL.cL].str..","
					--print(k,"=",v)
				else
					rL[rL.cL].str = rL[rL.cL].str..string.format("%q",tostring(v))
					rL[rL.cL].str = rL[rL.cL].str..","
					--print(k,"=",v)
				end		-- if type(v) == "table" then ends
			end		-- if not rL[rL.cL]._var and rL.cL == 1 then ends
		end		-- while true ends here
	end		-- do ends
	if string.sub(rL[rL.cL].str,-1,-1) == "," then
		rL[rL.cL].str = string.sub(rL[rL.cL].str,1,-2)
	end
	rL[rL.cL].str = rL[rL.cL].str.."}"
	return rL[rL.cL].str
end

local function createServer()
	-- Try opening the TCP server
	local serv,msg = socket.bind("*",port)
	local retmsg = {}

	if not serv then
		-- Try the next 100 port numbers
		for i=port,port+100 do
			serv,msg = socket.bind("*",i)
			if serv then
				port = i
				break
			end
		end
		if not serv then
			-- Return message is server creation failure
			retmsg[1] = "SERVER FAIL"
			retmsg[2] = msg
		end
	end	-- if not serv then
	if serv then
		retmsg[1] = "SERVER SUCCESS"
		retmsg[2] = port
	-- Send retmsg table to parent
	local client
	client,msg = socket.connect("localhost",parentPort)
	if client then
		client:send(tableToString(retmsg))
		client:close()
	end
	if serv then
		return true
	end
end

-- Main function to launch the iup loop
local function launchIUPLoop()
	
end


for i=1,#args,2 do
	if args[i] == "PARENT PORT" and args[i+1] and type(args[i+1]) == "number" then
		parentPort = args[i+1]
	elseif args[i] == "SERVER PORT" and args[i+1] and type(args[i+1]) == "number" then
		port = args[i+1]
	end
end
if parentPort and port then
	if createServer() then
		launchIUPLoop()
	end
end 	-- if parentPort and port then ends




