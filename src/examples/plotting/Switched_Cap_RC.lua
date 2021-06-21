-- To plot the frequency response of a switched capacitor filter
--[[
		    \			\
    Vin o--- \-----*---- \--------*----o Vout
				   |			  |
				   |			  |
				  ---			 ---
				  ---  Cr		 --- C
				   |			  |
				   |			  |
				   |			  |
				   V			  V

]]

require("LuaMath")
plot = require "lua-plot" 

local Cr = 10e-12	-- Switched Cap
local Fs = 	1e6		-- Sampling frequency
local C = 1.59e-9	-- Filter cap

-- The pole should be at Cr*Fs/(2*pi*C)

function func(x)
	return Cr/((Cr+C)*math.exp(x/Fs)-C)
end

do 
	local bp = plot.bodePlot{
		func = func,
		ini = 1,
		finfreq = 500e3,
		steps = 20
	}

	bp.mag:Show({title="Magnitude Plot",size="HALFxHALF"})
	bp.phase:Show({title="Phase Plot",size="HALFxHALF"})
	io.read()
end

-- Now lets do a simple magnitude plot up to 4MHz to show that the frequency plot is periodic with the sampling frequency
local xy = {}
for i = 0,4e6,100 do
	local lg = func(math.i*2*math.pi*i)
	xy[#xy + 1] = {i,20*math.log(math.abs(lg),10)}
end

p = plot.plot({})
p:AddSeries(xy)
p:Show()

io.read()



