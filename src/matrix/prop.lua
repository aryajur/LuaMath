-- Module for Matrix algebra functions

local modname = ...
local type = type

local M = {}
package.loaded[modname] = M
if setfenv then
	setfenv(1,M)
else
	_ENV = M
end


-- To get the matrix dimensions
function dim(m)
	if type(m) ~= "table" then
		return nil,"Matrix not a table."
	end
	local r,c
	r = #m
	if r == 0 then
		return 0	-- 0 size matrix
	end
	if type(m[1]) == "table" then
		c = #m[1]
	else
		return r	-- 1D matrix
	end
	for i = 2,r do
		if #m[i] ~= c then
			return nil,"Ill-formed Matrix"
		end
	end
	return r,c
end