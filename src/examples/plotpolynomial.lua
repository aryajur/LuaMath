-- Plot a polynomial

lm = require("LuaMath")
plot = require("lua-plot")

function func(x)
	return x^2
end

xy = {}
for i = -10,10,0.1 do
	xy[#xy+1] = {i,func(i)}
end

p = plot.plot({})

p:AddSeries(xy)

p:Show()

io.read()

