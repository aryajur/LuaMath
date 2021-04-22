-- Module to provide graph manipulation with sliders in LuaMath
local modname = ...
local type = type
local lm = require("LuaMath")
local lp = require("lua-plot")

local llthreads
do
    local ok
    ok, llthreads = pcall(require, "llthreads2")
    if not ok then llthreads = require"llthreads" end
end



local M = {} 
package.loaded[modname] = M
if setfenv then
	setfenv(1,M)
else
	_ENV = M
end

_VERSION = "1.19.09.05"

-- Function to validate the configuration table
local function validateConfig(cfg)
	-- It should have a key func which will return the y value when all the other parameters are available in the environment
	if not cfg.func or type(cfg.func) ~= "string" then
		return nil, "Cannot find the set of equations to solve"
	end
	local stat,msg = load(cfg.func)
	if not stat then
		return nil,msg
	end
	--_X key stores the name of the variable to sweep for the X axis
	if not cfg._X or type(cfg._X) ~= "string" or not cfg[cfg._X] or type(cfg[cfg._X]) ~= "table" or cfg[cfg._X].type ~= "domain" then
		return nil, "Cannot find the X axis domain."
	end
	return true
end

function new(config)
	local stat,msg = validateConfig(config)
	if not stat then
		return nil,msg
	end
	
end

