-- Include the sub modules searcher 
require("subModSearcher")
-- Setup a searcher to check for LuaMath modules also
package.searchers[#package.searchers + 1] = function(mod)
	-- Check if this is a multi hierarchy module
	-- modify the module name to include LuaMath
	local newMod = "LuaMath."..mod
	-- Now check if we can find this using all the searchers
	local totErr = ""
	for i = 1,#package.searchers do
		local r = package.searchers[i](newMod)
		if type(r) == "function" then
			return r
		end
		totErr = totErr..r
	end
	return totErr
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

__LuaMathVersion = "1.16.10.27"
