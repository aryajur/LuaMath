-- Module to add plotting functionality
-- This module launches the plot server
local modname = ...

local plots = {}

require("LuaMath")
local llthreads = require("llthreads")
local socket = require("socket")

local M = {} 
package.loaded[modname] = M
if setfenv then
	setfenv(1,M)
else
	_ENV = M
end


-- Launch the plot server
local port = 6348
local plotservercode = [[require("plot.plotserver")]]
local server,stat,conn
server = socket.bind("*",port)
if not server then
	-- Try the next 100 ports
	while not server do
		port = port + 1
		server = socket.bind("*",port)
	end
	if not server then
		package.loaded[modname] = nil
		return
	end
end

local plotserver = llthreads.new(plotservercode, "PARENT PORT", port)
stat = thread:start()
if not stat then
	-- Could not start the plotserver as a new thread
	package.loaded[modname] = nil
	return
end

-- Now wait for the connection
server:settimeout(2)
conn = server:accept()

if not conn then
	-- Did not get connection
	package.loaded[modname] = nil
	return
end
conn:settimeout(2)

-- Plotserver should be running and the connection socket is establed with conn
-- Now expose the API for plotting