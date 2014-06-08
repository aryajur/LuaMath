require("LuaMath")
--print(package.path)
--print(package.cpath)
local plot = require "plot" 

function func(x)
	return 1000/((1+x)*(1+x/100))
end

do 
	local bp = plot.bodePlot{
		func = func,
		ini = 0.01,
		finfreq = 1000,
		steps = 20
	}

	bp.mag:Show({title="Magnitude Plot",size="HALFxHALF"})
	bp.phase:Show({title="Phase Plot",size="HALFxHALF"})
	plot.listPlots()
	io.read()
end

collectgarbage()
-- Test Garbage collection
bp = plot.bodePlot{
	func = func,
	ini = 0.01,
	finfreq = 1000,
	steps = 20
}
plot.listPlots()
io.read()
plot.listPlots()
print("SHOW AGAIN MAG")
bp.mag:Show({title="Magnitude Plot",size="HALFxHALF"})
print("SHOW AGAIN PHASE")
bp.phase:Show({title="Phase Plot",size="HALFxHALF"})

print("LIST AGAIN")
plot.listPlots()
io.read()



