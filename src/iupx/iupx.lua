require 'iuplua'

if not iupx then iupx = {} end

function iupx.menu(templ)
	local items = {}
	for i = 1,#templ,2 do
		local label = templ[i]
		local data = templ[i+1]
		if type(data) == 'function' then
			item = iup.item{title = label}
			item.action = data
		elseif type(data) == 'nil' then
			item = iup.separator{}
		else
			item = iup.submenu {iupx.menu(data); title = label}
		end
		table.insert(items,item)
	end
	return iup.menu(items)
end

function iupx.show_dialog (tbl)
    local dlg = iup.dialog(tbl)
    dlg:show()
    iup.MainLoop()
end

function iupx.GetString (title,prompt,default)
	require "iupluacontrols"
	return iup.GetParam(title, nil,prompt.." %s\n",default or "")
end

function iupx.pplot (tbl)
	-- only load this functionality on demand! ---
	require 'iupx.iupxpplot'
	return iupxpplot.pplot(tbl)
end

function iupx.bodePlot(tbl)
	if type(tbl) ~= "table" then
		error("Expected table argument",2)
	end
	require "complex"


	if not tbl.func or not(type(tbl.func) == "function") then
		error("Expected func key to contain a function in the table",2)
	end
	local func = tbl.func

	local ini = tbl.ini or 0.01
	local fin = 10*ini
	local finfreq = tbl.finfreq or 1e6
	local mag = {}
	local phase = {}
	local lg = func(math.i*ini)
	mag[#mag+1] = {ini,20*math.log(math.abs(math.abs(lg)),10)}
	phase[#phase+1] = {ini,180/math.pi*math.atan2(lg.i,lg.r)}
	local magmax = mag[1][2]
	local magmin = mag[1][2]
	local phasemax = phase[1][2]
	local phasemin = phase[1][2]
	local steps = tbl.steps or 50	-- 50 points per decade
	repeat
		for i=1,steps do
			lg = func(math.i*(ini+i*(fin-ini)/steps))
			mag[#mag+1] = {ini+i*(fin-ini)/steps,20*math.log(math.abs(math.abs(lg)),10)}
			phase[#phase+1] = {ini+i*(fin-ini)/steps,180/math.pi*math.atan2(lg.i,lg.r)}
			if mag[#mag][2]>magmax then
				magmax = mag[#mag][2]
			end
			if phase[#phase][2] > phasemax then
				phasemax=phase[#phase][2]
			end
			if mag[#mag][2]<magmin then
				magmin = mag[#mag][2]
			end
			if phase[#phase][2] < phasemin then
				phasemin=phase[#phase][2]
			end
			--print(i,mag[#mag][1],mag[#mag][2])
		end
		ini = fin
		fin = ini*10
		--print("fin=",fin,fin<=1e6)
	until fin > finfreq
	local plotmag = iupx.pplot {TITLE = "Magnitude", GRID="YES", GRIDLINESTYLE = "DOTTED", AXS_XSCALE="LOG10", AXS_XMIN=tbl.ini or 0.01, AXS_YMAX = magmax+20, AXS_YMIN=magmin-20}
	local plotphase = iupx.pplot {TITLE = "Phase", GRID="YES", GRIDLINESTYLE = "DOTTED", AXS_XSCALE="LOG10", AXS_XMIN=tbl.ini or 0.01, AXS_YMAX = phasemax+10, AXS_YMIN = phasemin-10}
	plotmag:AddSeries(mag)
	plotphase:AddSeries(phase)
	--plotmag:AddSeries({{0,0},{10,10},{20,30},{30,45}})
	return iup.vbox {plotmag,plotphase}
	--return plotmag
end


