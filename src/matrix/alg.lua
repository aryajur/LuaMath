-- Module for Matrix algebra functions

local modname = ...
local math = require("math")
local prop = require("matrix.prop")
local type = type
local print = print

local M = {}
package.loaded[modname] = M
if setfenv then
	setfenv(1,M)
else
	_ENV = M
end



-- To add 2 (1D or 2D) Matrices
function add(m1,m2)
	local r1,c1 = prop.dim(m1)
	if not r1 then 
		return nil,c1.." Matrix: m1"
	end
	local r2,c2 = prop.dim(m2)
	if not r1 then 
		return nil,c1.." Matrix: m1"
	end
	if not( r1==r2 and (c1 and c2 and c1 == c2 or not c1 and not c2 ) ) then
		return nil,"Matrix not the same sizes"
	end
	local r,c = r1,c1
	local function add1D(m1,m2)
		local m = {}
		for i = 1,r do
			m[i] = m1[i] + m2[i]
		end
		return m
	end
	local function add2D(m1,m2)
		local m = {}
		for i = 1,r do
			m[i] = {}
			for j = 1,c do
				m[i][j] = m1[i][j] + m2[i][j]
			end
		end
		return m
	end
	
	if not c1 then
		return add1D(m1,m2)
	else
		return add2D(m1,m2)
	end
end

-- To subtract 2 (1D or 2D) Matrices (m1-m2)
function sub(m1,m2)
	local r1,c1 = prop.dim(m1)
	if not r1 then 
		return nil,c1.." Matrix: m1"
	end
	local r2,c2 = prop.dim(m2)
	if not r1 then 
		return nil,c1.." Matrix: m1"
	end
	if not( r1==r2 and (c1 and c2 and c1 == c2 or not c1 and not c2 ) ) then
		return nil,"Matrix not the same sizes"
	end
	local r,c = r1,c1
	local function sub1D(m1,m2)
		local m = {}
		for i = 1,r do
			m[i] = m1[i] - m2[i]
		end
		return m
	end
	local function sub2D(m1,m2)
		local m = {}
		for i = 1,r do
			m[i] = {}
			for j = 1,c do
				m[i][j] = m1[i][j] - m2[i][j]
			end
		end
		return m
	end
	
	if not c1 then
		return sub1D(m1,m2)
	else
		return sub2D(m1,m2)
	end
end