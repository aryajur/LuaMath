-- Script to demonstrate signal filtering

require("LuaMath")
filter = require("signal.filter")

-- Make a square wave signal
sig = {}
for i = 1,10 do
	for j = 1,5 do
		sig[#sig + 1] = 1
	end
	for k = 1,5 do
		sig[#sig + 1] = 0
	end
end

-- Now use the Binomial filter
fsig = filter.binomial(sig)