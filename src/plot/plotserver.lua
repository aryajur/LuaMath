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
-- LIST PLOTS - List all plot numbers and objects in memory

-- SOCKET COMMAND TO/FROM PARENT STRUCTURE
-- It is a Lua table with the command/Response on index 1 followed by extra arguments on following indices

-- SERVER RESPONSES
-- ACKNOWLEDGE
-- ERROR

socket = require("socket")	-- socket is used to communicate with the main program and detect when to shut down
require("LuaMath")
local iup = require("iuplua")
require("iuplua_pplot")
local t2s = require("plot.tableToString")

local timer
local client			-- client socket object connection to parent process
local managedPlots = {}
local plot2Dialog = {}
local managedDialogs = {}
local exitProg

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
			--print(msg)
			msg = t2s.stringToTable(msg)
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
						managedPlots[msg[2]]:AddSeries(msg[3],msg[4],msg[5])
						retmsg = [[{"ACKNOWLEDGE"}]].."\n"
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
						if not msg[3] or not type(msg[3]) == "table" then
							msg[3] = {title="Plot "..tostring(msg[2]),size="HALFxHALF"}
						else
							if msg[3].title then
								msg[3].title = "Plot "..tostring(msg[2])..":"..msg[3].title
							else
								msg[3].title = "Plot "..tostring(msg[2])
							end
						end
						msg[3][1] = managedPlots[msg[2]]
						managedDialogs[#managedDialogs + 1] = iup.dialog(msg[3])
						managedDialogs[#managedDialogs]:show()
						plot2Dialog[msg[3][1]] =  managedDialogs[#managedDialogs]
						local dlg = #managedDialogs
						local dlgObject = managedDialogs[#managedDialogs]
						function dlgObject:close_cb()
							for k,v in pairs(plot2Dialog) do
								if v == managedDialogs[dlg] then
									plot2Dialog[k] = nil
								end
							end
							iup.Destroy(managedDialogs[dlg])
							managedDialogs[dlg] = nil
							return iup.IGNORE
						end
						retmsg = [[{"ACKNOWLEDGE"}]].."\n"
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
						retmsg = [[{"ACKNOWLEDGE"}]].."\n"
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
						retmsg = [[{"ACKNOWLEDGE"}]].."\n"
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
				elseif msg[1] == "LIST PLOTS" then
					print("Plotserver list:")
					for k,v in pairs(managedPlots) do
						print(k,v)
					end
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

--print("Starting plotserver")
--print("Parent Port number=",parentPort)
if parentPort then
	if connectParent() then
		setupTimer()
		--print("Timer is setup. Now starting mainloop")
		while not exitProg do
			iup.MainLoop()
		end
	else
		--print("Connect Parent unsuccessful")
	end
end 	-- if parentPort and port then ends





