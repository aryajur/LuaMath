-- Plot a series

lm = require("LuaMath")
plot = require("lua-plot")

function func(x)
	return x^2
end

y = {}
for i = -10,10,0.5 do
	y[#y+1] = func(i)
end

p = plot.plot({})

--p:AddSeries(y,nil,{DS_MODE="MARK"})
--p:AddSeries(y,nil,{DS_MODE="STEP"})
--p:AddSeries(y,nil,{DS_MODE="MARK",DS_MARKSTYLE="CIRCLE",DS_MARKSIZE=5})
p:AddSeries(y,nil,{DS_MODE="MARKSTEM",DS_MARKSTYLE="CIRCLE",DS_MARKSIZE=3})

p:Show()

io.read()

