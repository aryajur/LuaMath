-- Module to calculate properties of data

local modname = ...
local math = require("math")

local M = {}
package.loaded[modname] = M
if setfenv then
	setfenv(1,M)
else
	_ENV = M
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

-- Function to find the factorial of a number
function fact(n)
	if n < 0 then return nil,"Negative numbers not allowed" end
	if n == 0 or n == 1 then return 1 end
	local fact = 1
	for i = 2,n do
		fact = fact*i
	end
	return fact
end

-- Find the permutations of n items taken r at a time
-- returns n!/(n-r)!
function nPr(n,r)
	if n<0 or r<0 or n<r then
		return nil,"Negative numbers not allowed"
	end
	return fact(n)/fact(n-r)
end

-- Find the Combinations of n items taken r at a time
-- returns n!/[r!(n-r)!
function nCr(n,r)
	if n<0 or r<0 or n<r then
		return nil,"Negative numbers not allowed"
	end
	return fact(n)/(fact(r)*fact(n-r))
end