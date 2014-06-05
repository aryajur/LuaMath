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
