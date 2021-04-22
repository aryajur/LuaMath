-- Include the sub modules searcher 
require("subModSearcher")

-- Setup a searcher to check for LuaMath modules also
local skipSearcher
package.searchers[#package.searchers + 1] = function(mod)
	-- Check if this is a multi hierarchy module
	-- modify the module name to include LuaMath
	local newMod = "LuaMath."..mod
	--print("Search for "..newMod)
	-- Now check if we can find this using all the searchers
	local totErr = ""
	for i = 1,#package.searchers do
		if package.searchers[i] ~= skipSearcher then
			local r = package.searchers[i](newMod)
			if type(r) == "function" then
				--print("Found",r)
				return r
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
