-- Module to calculate properties of data

local modname = ...
local math = require("math")

local M = {}
package.loaded[modname] = M
if setfenv then
	setfenv(1,M)
else
	_ENV
end

-- Arithmetic mean of a series of numbers
function arMean(list)
	local sum = 0
	for i = 1,#list do
		sum = sum + list[i]
	end
	return sum/#list
end

-- Mean for a stream of numbers
-- mean is the previous mean
-- n is the number of numbers from which the previous mean was calculated
-- num is the new number in the stream
function arMeanS(mean,n,num)
	local fac = n/(n+1)
	return mean*fac + num/(n+1)	
end