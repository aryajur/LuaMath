-- Module to provide circle discretization

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