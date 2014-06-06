if not package.path:find([[;.\?.lua]],1,true) and not (package.path:sub(1,#[[.\?.lua;]])==[[.\?.lua;]]) then
	package.path = [[.\?.lua;]]..package.path
end
if not package.path:find([[;.\?\init.lua]],1,true) and not (package.path:sub(1,#[[.\?\init.lua;]])==[[.\?\init.lua;]]) then
	package.path = [[.\?\init.lua;]]..package.path
end
if not package.path:find([[;.\LuaMath\?.lua]],1,true) and not (package.path:sub(1,#[[.\LuaMath\?.lua;]])==[[.\LuaMath\?.lua;]]) then
	package.path = [[.\LuaMath\?.lua;]]..package.path
end
if not package.path:find([[;.\LuaMath\?\init.lua]],1,true) and not (package.path:sub(1,#[[.\LuaMath\?\init.lua;]])==[[.\LuaMath\?\init.lua;]]) then
	package.path = [[.\LuaMath\?\init.lua;]]..package.path
end
if not package.cpath:find([[;.\?.dll]],1,true) and not (package.cpath:sub(1,#[[.\?.dll;]])==[[.\?.dll;]]) then
	package.cpath = [[.\?.dll;]]..package.cpath
end
if not package.cpath:find([[;.\?\?.dll]],1,true) and not (package.cpath:sub(1,#[[.\?\?.dll;]])==[[.\?\?.dll;]]) then
	package.cpath = [[.\?\?.dll;]]..package.cpath
end
if not package.cpath:find([[;.\LuaMath\?.dll]],1,true) and not (package.cpath:sub(1,#[[.\LuaMath\?.dll;]])==[[.\LuaMath\?.dll;]]) then
	package.cpath = [[.\LuaMath\?.dll;]]..package.cpath
end
if not package.cpath:find([[;.\LuaMath\?\?.dll]],1,true) and not (package.cpath:sub(1,#[[.\LuaMath\?\?.dll;]])==[[.\LuaMath\?\?.dll;]]) then
	package.cpath = [[.\LuaMath\?\?.dll;]]..package.cpath
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
