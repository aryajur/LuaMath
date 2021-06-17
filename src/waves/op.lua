-- Module to perform operations on waveforms
-- A waveform is a dual array i.e. a set of values associated with a set of time values or frequency values or any other x values

local modname = ...
local math = require("math")
local table = require("table")
local type = type

local print = print

local M = {}
package.loaded[modname] = M
if setfenv then
	setfenv(1,M)
else
	_ENV = M
end

-- To implement the cross detection
--[[
* wave is the array with the wave readings
* t is the array with corresponding x axis readings
* rise [OPTIONAL] is the threshold that the wave rises to trigger a rising event
* fall [OPTIONAL] is the threshold that the wave falls to trigger the fall event
* pts [OPTIONAL] is the number of events to detect and return. If not given then all events returned. 

One of rise or fall must be given
The events are returned as an array of time points with each time point being the 1st time point at which the event detection was satisfied

]]
function cross(wave,t,rise,fall,pts)
	if not rise and not fall then
		return nil,"No thresholds given"
	end
	if type(wave) ~= "table" or #wave == 0 then 
		return nil,"The waveform should be an array."
	end
	if type(t) ~= "table" or #t == 0 then
		return nil,"The x values should be an array."
	end
	if #t ~= #wave then
		return nil,"The wave and the x values arrays should be of the same size"
	end
	local function findRiseEvent(ind)
		local epreset = wave[ind] < rise	-- Event preset condition
		local risemode
		for i = ind+1,#t do
			risemode = (wave[i]-wave[i-1]) > 0
			if risemode and epreset and wave[i] > rise then
				-- Rise event happened
				return i
			end
			epreset = wave[i] < rise
		end
		-- No rise event found
		return nil
	end
	
	local function findFallEvent(ind)
		local epreset = wave[ind] > fall
		local fallmode
		for i = ind+1,#t do
			fallmode = (wave[i]-wave[i-1]) < 0
			if fallmode and epreset and wave[i] < fall then
				-- Fall event happened
				return i
			end
			epreset = wave[i] > fall
		end
		-- No rise event found
		return nil
	end
	
	local events = {}
	local e		-- To store the event index
	local i = 1
	local found = true
	while found do
		found = false
		if rise then
			e = findRiseEvent(i)
			if e then
				found = true
				events[#events + 1] = e
			end
		end
		if fall then
			e = findFallEvent(i)
			if e then
				found = true
				events[#events + 1] = e
			end
		end
		if pts and #events >= pts then
			for j = #events,pts + 1,-1 do
				table.remove(events,j)
			end
			table.sort(events)
			return events
		end
		if #events > 1 then
			i = math.max(events[#events],events[#events-1])
		else
			i = events[1]
		end
	end
	table.sort(events)
	return events
end