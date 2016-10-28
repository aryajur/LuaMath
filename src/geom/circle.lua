-- Module to provide circle discretization
-- This module provides useful routines for circles

local modname = ...
local math = require("math")
local type = type
local print = print

local M = {}
package.loaded[modname] = M
if setfenv then
	setfenv(1,M)
else
	_ENV = M
end

-- Function to discretize the area of a circle using rectangles
-- radius is the radius of the circle
-- seg is an optional element saying how many equal height rectangles to stack on top of the centre square on each of its 4 sides
-- It returns the length and width of all the rectangles and their center x,y coordinates with respect to the center of the circle
	-- l is with x axis and w is with y axis
-- It also returns the error % of the area of the circle - area of discretized shape
-- The rectangles returned by the routine always lie within the boundary of the circle
function discreteRect(radius,seg)
	local n = seg or 3
	local rects = {}
	-- The 1st one is the central square
	rects[1] = {l=math.sqrt(2)*radius,w=math.sqrt(2)*radius,x=0,y=0}
	local totArea = rects[1].l^2
	local d = radius/n*(1-1/math.sqrt(2))
	local p = rects[1].l/2
	for i = 1,n do
		local m = math.sqrt(radius^2-(p+d)^2)
		-- Add the 4 rectangles to rects
		rects[#rects + 1] = {l = 2*m, w = d, x = 0, y = p+d/2}
		rects[#rects + 1] = {l = d, w = 2*m, x = -(p+d/2), y = 0}
		rects[#rects + 1] = {l = d, w = 2*m, x = p+d/2, y = 0}
		rects[#rects + 1] = {l = 2*m, w = d, x = 0, y = -(p+d/2)}
		totArea = 8*m*d
		-- Update the p
		p = p+d
	end
	return rects,(1-totArea/(math.pi*radius^2))*100
end