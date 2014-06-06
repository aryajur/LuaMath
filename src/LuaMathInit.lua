if not package.path:find([[;.\?.lua]],1,true) then
	package.path = package.path..[[;.\?.lua]]
end
if not package.path:find([[;.\?\init.lua]],1,true) then
	package.path = package.path..[[;.\?\init.lua]]
end
if not package.cpath:find([[;.\?.dll]],1,true) then
	package.cpath = package.cpath..[[;.\?.dll]]
end
if not package.cpath:find([[;.\?\?.dll]],1,true) then
	package.cpath = package.cpath..[[;.\?\?.dll]]
end

if math.log(10,10) ~= 1 then
	local origLog = math.log
	math.log = function(x,base)
		if not base then
			return origLog(x)
		else
			return origLog(x)/origLog(base)
		end
	end
end

__LuaMathVersion = "1.14.06.05"
