-- Cartesian plotter code
local args = {...}		-- arguments given by parent
-- Search for CONFIG and store it in parentPort global variable
for i=1,#args,2 do
	if args[i] == "PARENT PORT" and args[i+1] and type(args[i+1]) == "number" then
		parentPort = math.floor(args[i+1])
	end
	if args[i] == "CHUNKED_LIMIT" and args[i+1] and type(args[i+1]) == "number" then
		CHUNKED_LIMIT = math.floor(args[i+1])
	end
end
