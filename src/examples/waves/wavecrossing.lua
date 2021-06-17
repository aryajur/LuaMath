-- Script to demonstrate usage of waves cross function in Lua Math

lm = require("LuaMath")
waveops = require("waves.op")	-- Wave operations module

-- First let us create a sine wave
 w = {}
 t = {}
 -- Period of sine wave is 1 second. We will sample it at each 0 crossing and 99 times in between. So the sampling rate is 1/100 seconds
 -- We will take 10 periods
 for i = 1,1000 do
	t[i] = i/100
	w[i] = math.sin(2*math.pi*t[i])
 end
 
 -- The section below plots the wave to see what we have. It can be commented out as a block to skip
plot = require("lua-plot")
p = plot.plot({})
p:AddSeries(t,w)
p:Show()

local function printpts(pts)
	if #pts == 0 then
		print("Nothing in pts")
	else
		print("pts has:")
	end
	for i = 1,#pts do
		io.write(t[pts[i]].."\t")
	end
	io.write("\n")
end
-- Now lets find the time points where the wave crosses the 0 threshold while rising
-- It should be the seconds 1,2,3,4,5,6,7,8,9 but since the crossing happens after these times
--   the time points should be 1.01,2.01,3.01...,8.01,9.01
print("Time points where the wave crosses the threshold 0 rising:")
pts = waveops.cross(w,t,0)	-- Only rising events selected and all points returned
printpts(pts)

-- Now lets find the time points where the wave crosses the 0 threshold while falling
print("Time points where the wave crosses the threshold 0 falling:")
pts = waveops.cross(w,t,nil,0)	-- Only rising events selected and all points returned
printpts(pts)

-- Now lets find the time points where the wave crosses the 0 threshold while rising or falling
print("Time points where the wave crosses the threshold 0 rising and falling:")
pts = waveops.cross(w,t,0,0)	-- Only rising events selected and all points returned
printpts(pts)

io.read()
