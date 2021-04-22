-- Module to provide functions to handle distributions

local modname = ...
local math = require("math")
--local print = print

local M = {}
package.loaded[modname] = M
if setfenv then
	setfenv(1,M)
else
	_ENV = M
end

-- Function to generate a Gaussian random distribution using the Box Muller algorithm
-- Reference: https://en.wikipedia.org/wiki/Box%E2%80%93Muller_transform
function gaussRandom(mean,sigma)
	mean = mean or 0
	sigma = sigma or 1
	local u,v,s
	repeat
		u = math.random()*2-1
		v = math.random()*2-1
		s = u*u+v*v
		--print(s)
	until not(s==0 or s>=1)
	return math.sqrt(-2*math.log(s)/s)*u*sigma+mean
end