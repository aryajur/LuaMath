require("LuaMath")
plot = require "lua-plot" 

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
	print("Now printing the list of objects local and in plotserver.")
	print("EXPECTED: 2 local plots, 2 plotserver plots, 2 plotserver dialogs\n")
	plot.listPlots()
	print("\nNow close the phase plot and press a key to garbage collect the local plots")
	io.read()
end

collectgarbage()
print("\n\n")
print("Now printing the list of objects local and in plotserver.")
print("EXPECTED: 0 local plots, 1 plotserver plot, 1 plotserver dialog\n")
plot.listPlots()
print("\nNow press a key to create 2 more plots (1 bode plot object) in bp variable in global space")
io.read()

-- Test Garbage collection
bp = plot.bodePlot{
	func = func,
	ini = 0.01,
	finfreq = 1000,
	steps = 20
}
print("\n\n")
print("Now printing the list of objects local and in plotserver.")
print("EXPECTED: 2 local plots, 3 plotserver plot, 1 plotserver dialog\n")
plot.listPlots()
print("\nNow close the original Mag plot and press a key")
io.read()
print("\n\n")
print("Now printing the list of objects local and in plotserver.")
print("EXPECTED: 2 local plots, 2 plotserver plot, 0 plotserver dialog\n")
plot.listPlots()
print("\nNow press enter to show the plots in the bp variable")
io.read()

print("SHOW AGAIN MAG")
bp.mag:Show({title="Magnitude Plot",size="HALFxHALF"})
print("SHOW AGAIN PHASE")
bp.phase:Show({title="Phase Plot",size="HALFxHALF"})

print("\n\n")
print("Now printing the list of objects local and in plotserver.")
print("EXPECTED: 2 local plots, 2 plotserver plot, 2 plotserver dialog\n")
plot.listPlots()
print("\nNow close both the plots and press enter to create a window object in win variable to hold the plots vertically")
io.read()

win = plot.window{1,1; title="Bode Plots"}	-- window with 1 slot in each 1st row and 1 slot in 2nd row
print("\n\n")
print("Now printing the list of objects local and in plotserver.")
print("EXPECTED: 2 local plots, 1 local window, 2 plotserver plot, 0 plotserver dialog, 1 plotserver window\n")
plot.listPlots()
print("\nNow press enter to add the plots to the window and then show the window")
io.read()

win:AddPlot(bp.mag,{1,1})
win:AddPlot(bp.phase,{2,1})
print("Result of show:", win:Show())

print("\n\n")
print("Now printing the list of objects local and in plotserver.")
print("EXPECTED: 2 local plots, 1 local window, 2 plotserver plot, 0 plotserver dialog, 1 plotserver window\n")
plot.listPlots()
print("\nNow press enter to garbage collect the window and then see the object list again")
io.read()

win = nil

print("\n\n")
print("Now printing the list of objects local and in plotserver.")
print("EXPECTED: 2 local plots, 0 local window, 2 plotserver plot, 0 plotserver dialog, 1 plotserver window\n")
plot.listPlots()
print("\nNow close the window and press enter to display the objects again")
io.read()

print("\n\n")
print("Now printing the list of objects local and in plotserver.")
print("EXPECTED: 2 local plots, 0 local window, 2 plotserver plot, 0 plotserver dialog, 0 plotserver window\n")
plot.listPlots()
print("\nNow press enter to finish")
io.read()





