-- Script to demonstrate signal filtering

require("LuaMath")
filter = require("signal.filter")

-- Make a square wave signal
sig = {}
x = {}
for i = 1,10 do
	for j = 1,5 do
		sig[#sig + 1] = 1
		x[#x + 1] = #x + 1
	end
	for k = 1,5 do
		sig[#sig + 1] = 0
		x[#x + 1] = #x + 1
	end
end

-- Now use the Binomial filter
fsig = filter.binomial(sig)

-- Now plot the signal and the filtered signal
plot = require("lua-plot")

p = plot.plot({})

p:AddSeries(x,sig)--,{DS_MODE="MARK",DS_MARKSTYLE="CIRCLE"})
p:AddSeries(x,fsig)--,{DS_MODE="MARK",DS_MARKSTYLE="DIAMOND"})

p:Show()

io.read()