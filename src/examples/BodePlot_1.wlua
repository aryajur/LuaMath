require("LuaMath")
--print(package.path)
--print(package.cpath)
local plot = require "plot" 

function func(x)
	return 1000/((1+x)*(1+x/100))
end

bp = plot.bodePlot{
	func = func,
	ini = 0.01,
	finfreq = 1000,
	steps = 20
}

--iupx.show_dialog{plot; title="Easy Plotting",size="QUARTERxQUARTER"}
--iupx.show_dialog{bp; title="Bode Plot",size="HALFxHALF"}

