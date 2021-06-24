-- Plot a series

lm = require("LuaMath")
plot = require("lua-plot")

function func(x)
	return x^2
end

y = {}
for i = -10,10,0.1 do
	y[#y+1] = func(i)
end

p = plot.plot({})

p:AddSeries(nil,y)

p:Show()

io.read()

