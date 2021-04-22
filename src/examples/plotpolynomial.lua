-- Plot a polynomial

lm = require("LuaMath")
plot = require("lua-plot")

function func(x)
	return x^2
end

xy = {}
function genxy()
	for i = -10,10,0.1 do
		xy[#xy+1] = {i,func(i)}
	end
end

genxy()

p = plot.plot({})

p:Attributes({AXS_XAUTOMIN="NO",AXS_XAUTOMAX="NO",AXS_YAUTOMIN="NO",AXS_YAUTOMAX="NO",AXS_XMAX=10,AXS_XMIN=-10,AXS_YMAX=200,AXS_YMIN=0})

ds = p:AddSeries(xy)

p:Show()

io.read()

sign = -1
for i = 0,99 do
	p:Attributes({REMOVE="CURRENT"})
	local c = i%20
	if c == 0 then
		sign = sign * -1
	end
	if sign == -1 then
		c = 20 - c
	end
	func = function(x) return c/10*x^2 end
	xy = {}
	genxy()
	p:AddSeries(xy)
	p:Redraw()
	io.read()
end