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
function discreteRect(radius)
	
	
end