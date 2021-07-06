-- Include the sub modules searcher 
require("subModSearcher")

-- Setup a searcher to check for LuaMath modules also
local key = "searchers"
if _VERSION == "Lua 5.1" then
	key = "loaders"
end
local skipSearcher
package[key][#package[key] + 1] = function(mod)
	-- Check if this is a multi hierarchy module
	-- modify the module name to include LuaMath
	local newMod = "LuaMath."..mod
	-- Now check for the special case when LuaMath has a submodule and its code is in its src subdirectory
	-- So a path definition of ?\A\?.lua will be translated to:
	-- LuaMath\A\mod\src\mod.lua   
	-- Get the last name
	local last = mod:match("%.?([^%.]+)$")
	local newMod1 = "LuaMath."..mod..".src."..last
	--print("Search for "..newMod)
	-- Now check if we can find this using all the searchers
	local totErr = ""
	for i = 1,#package[key] do
		if package[key][i] ~= skipSearcher then
			local r,path = package[key][i](newMod)
			if type(r) == "function" then
				--print("Found",r)
				return r,path
			end
			totErr = totErr..r
			local r,path = package[key][i](newMod1)
			if type(r) == "function" then
				--print("Found",r)
				return r,path
			end
			totErr = totErr..r
		end
	end
	return totErr
end

skipSearcher = package.searchers[#package.searchers]

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

if math.atan(1) == math.atan(1,2) then
	math.atan = function(y,x)
		x = x or 1
		return math.atan2(y,x)
	end
else
	math.atan2 = math.atan
end

return {
	_VERSION = "1.21.07.06"		-- LuaMath version tracking
}
