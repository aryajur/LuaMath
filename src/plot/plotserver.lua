-- Plotserver.lua
-- This file is launched by iupx module to create a plotting server
-- All plotting requests go to this file once launched using LuaSocket
-- This allows user to have plots simultaneously with the lua interpreter 
-- using the standard lua interpreter
-- Milind Gupta 6/6/2014

-- SERVER SOCKET COMMANDS
-- END	- Shutdown and exit
-- PLOT - Create a plot object, 2nd index contains the table of Attributes for the plot
-- ADD DATA - Add data points to a plot
-- SHOW PLOT- Display the plot on the screen
-- REDRAW - Redraw the indicated plot
-- SET ATTRIBUTES - Set the plot attributes
-- DESTROY - Command to mark a plot object for destruction

-- SOCKET COMMAND TO/FROM PARENT STRUCTURE
-- It is a Lua table with the command/Response on index 1 followed by extra arguments on following indices

-- SERVER RESPONSES
-- ACKNOWLEDGE
-- ERROR

socket = require("socket")	-- socket is used to communicate with the main program and detect when to shut down
require("LuaMath")
local iup = require("iuplua")
require("iuplua_pplot")

local args = {...}		-- arguments given by parent
local parentPort 
local timer
local client			-- client socket object connection to parent process
local managedPlots = {}
local plot2Dialog = {}
local managedDialogs = {}
local exitProg

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

local function connectParent()
	-- Try opening the TCP server
	local msg
	local retmsg = {}
	client,msg = socket.connect("localhost",parentPort)

	if not client then
		return nil
	end	-- if not client then
	client:settimeout(0.01)
	return true
end

function pplot (tbl)

	if tbl.AXS_BOUNDS then
		local t = tbl.AXS_BOUNDS
		tbl.AXS_XMIN = t[1]
		tbl.AXS_YMIN = t[2]
		tbl.AXS_XMAX = t[3]
		tbl.AXS_YMAX = t[4]
	end

    -- the defaults for these values are too small, at least on my system!
    if not tbl.MARGINLEFT then tbl.MARGINLEFT = 30 end
    if not tbl.MARGINBOTTOM then tbl.MARGINBOTTOM = 35 end

    -- if we explicitly supply ranges, then auto must be switched off for that direction.
    if tbl.AXS_YMIN then tbl.AXS_YAUTOMIN = "NO" end
    if tbl.AXS_YMAX then tbl.AXS_YAUTOMAX = "NO" end
    if tbl.AXS_XMIN then tbl.AXS_XAUTOMIN = "NO" end
    if tbl.AXS_XMAX then tbl.AXS_XAUTOMAX = "NO" end

    local plot = iup.pplot(tbl)
    plot.End = iup.PPlotEnd
    plot.Add = iup.PPlotAdd
    function plot.Begin ()
        return iup.PPlotBegin(plot,0)
    end

    function plot:AddSeries(xvalues,yvalues,options)
        plot:Begin()
        if type(xvalues[1]) == "table" then
            options = yvalues
            for i,v in ipairs(xvalues) do
                plot:Add(v[1],v[2])
            end
        else
            for i = 1,#xvalues do
                plot:Add(xvalues[i],yvalues[i])
            end
        end
        plot:End()
        -- set any series-specific plot attributes
        if options then
            -- mode must be set before any other attributes!
            if options.DS_MODE then
                plot.DS_MODE = options.DS_MODE
                options.DS_MODE = nil
            end
            for k,v in pairs(options) do
                plot[k] = v
            end
        end
    end
    function plot:Redraw()
        plot.REDRAW='YES'
    end
    return plot
end

-- convert str to table
local stringToTable(str)
	local f
	local safeenv = {}
	if loadstring then
		f = loadstring("return "..str)
		setfenv(f,safeenv)
	else
		f = load("return "..str,nil,"bt",safeenv)
	end
	local stat,tab
	stat,tab = pcall(f)
	if stat and tab and type(tab) == "table" then
		return tab
	end
end

-- Main function to launch the iup loop
local function setupTimer()
	-- Setup timer to run housekeeping
	timer = iup.timer{time = 10, run = "YES"}	-- run timer with every 10ms action
	local retry
	local destroyQ = {}
	function timer:action_cb()
		local err,retmsg
		timer.run = "NO"
		-- Check if any plots in destroyQ and if they can be destroyed to free up memory
		if #destroyQ > 0 then
			local i = 1
			while i<=#destroyQ do
				if not plot2Dialog[destroyQ[i]] then
					-- destroy the plot data
					for k,v in pairs(managedPlots) do
						if v == destroyQ[i] then
							managedPlots[k] = nil
							break
						end
					end
					iup.Destroy(destroyQ[i])
					table.remove(destroyQ,i)
				else
					i = i + 1
				end
			end
		end
		if retry then
			msg,err = client:send(retry)
			if not msg then
				if err == "closed" then
					exitProg = true
					iup.Close()
				end
			else
				-- message sent successfully
				retry = nil
			end
			timer.run = "YES"
			return
		end
		-- Receive messages from Parent process if any
		msg,err = client:receive("*l")
		if msg then
			-- convert msg to table
			msg = stringToTable(msg)
			if msg then
				if msg[1] == "END" then
					exitProg = true
					iup.Close()
				elseif msg[1] == "PLOT" then
					-- Create a plot and return the plot index
					managedPlots[#managedPlots + 1] = pplot(msg[2])
					retmsg = [[{"ACKNOWLEDGE",]]..tostring(#managedPlots).."}\n"
					msg,err = client:send(retmsg)
					if not msg then
						if err == "closed" then
							exitProg = true
							iup.Close()
						elseif err == "timeout" then
							retry = retmsg
						end
					end
				elseif msg[1] == "ADD DATA" then
					if managedPlots[msg[2]] then
						-- Add the data to the plot
						managedPlots[msg[2]]:AddSeries(msg[3])
						retmsg = [[{ACKNOWLEDGE"}]].."\n"
					else
						retmsg = [[{"ERROR","No Plot present at that index"}]].."\n"
					end
					msg,err = client:send(retmsg)
					if not msg then
						if err == "closed" then
							exitProg = true
							iup.Close()
						elseif err == "timeout" then
							retry = retmsg
						end
					end
				elseif msg[1] == "SHOW PLOT" then
					if managedPlots[msg[2]] then
						msg[3][1] = managedPlots[msg[2]]
						managedDialogs[#managedDialogs + 1] = iup.dialog(msg[3])
						managedDialogs[#managedDialogs]:show()
						plot2Dialog[msg[3][1]] =  managedDialogs[#managedDialogs]
						local dlg = #managedDialogs
						function managedDialogs[#managedDialogs]:close_cb()
							for k,v in pairs(plot2Dialog) do
								if v == managedDialogs[dlg] then
									plot2Dialog[k] = nil
								end
							end
							iup.Destroy(managedDialogs[dlg])
							managedDialogs[dlg] = nil
							return iup.IGNORE
						end
						retmsg = [[{ACKNOWLEDGE"}]].."\n"
					else
						retmsg = [[{"ERROR","No Plot present at that index"}]].."\n"
					end
					msg,err = client:send(retmsg)
					if not msg then
						if err == "closed" then
							exitProg = true
							iup.Close()
						elseif err == "timeout" then
							retry = retmsg
						end
					end
				elseif msg[1] == "REDRAW" then
					if managedPlots[msg[2]] then
						managedPlots[msg[2]]:Redraw()
						retmsg = [[{ACKNOWLEDGE"}]].."\n"
					else
						retmsg = [[{"ERROR","No Plot present at that index"}]].."\n"
					end
					msg,err = client:send(retmsg)
					if not msg then
						if err == "closed" then
							exitProg = true
							iup.Close()
						elseif err == "timeout" then
							retry = retmsg
						end
					end
				elseif msg[1] == "DESTROY" then
					if managedPlots[msg[2]] then
						-- destroy the plot data
						if not plot2Dialog[managedPlots[msg[2]]] then
							iup.Destroy(managedPlots[msg[2]])
							managedPlots[msg[2]] = nil
						else
							destroyQ[#destroyQ + 1] = managedPlots[msg[2]]
						end
						retmsg = [[{ACKNOWLEDGE"}]].."\n"
					else
						retmsg = [[{"ERROR","No Plot present at that index"}]].."\n"
					end
					msg,err = client:send(retmsg)
					if not msg then
						if err == "closed" then
							exitProg = true
							iup.Close()
						elseif err == "timeout" then
							retry = retmsg
						end
					end
				elseif msg[1] == "SET ATTRIBUTES" then
				else
					retmsg = [[{"ERROR","Command not understood"}]].."\n"
					msg,err = client:send(retmsg)
					if not msg then
						if err == "closed" then
							exitProg = true
							iup.Close()
						elseif err == "timeout" then
							retry = retmsg
						end
					end
				end
			else		-- if msg then (If stringToTable returned something)
				retmsg = [[{"ERROR","Message not understood"}]].."\n"
				msg,err = client:send(retmsg)
				if not msg then
					if err == "closed" then
						exitProg = true
						iup.Close()
					elseif err == "timeout" then
						retry = retmsg
					end
				end
			end		-- if msg then (If stringToTable returned something)
		elseif err == "closed" then
			-- Exit this program as well
			exitProg = true
			iup.Close()
		end
		timer.run = "YES"
	end		-- function timer:action_cb() ends
end


for i=1,#args,2 do
	if args[i] == "PARENT PORT" and args[i+1] and type(args[i+1]) == "number" then
		parentPort = args[i+1]
	end
end
if parentPort then
	if connectParent() then
		setupTimer()
		while not exitProg do
			iup.MainLoop()
		end
	end
end 	-- if parentPort and port then ends





