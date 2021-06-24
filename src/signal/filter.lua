-- Module to implement signal filtering
-- NOTE: signal is just an array of values. It is a discrete signal

local modname = ...
local math = require("math")
local table = require("table")
local statData = require("stat.data")
local type = type

local print = print

local M = {}
package.loaded[modname] = M
if setfenv then
	setfenv(1,M)
else
	_ENV = M
end

_VERSION = "1.21.06.24"

-- Function to do the Binomial Smoothing on a signal
-- sig is the signal array
-- pts [DEFAULT=3] are the number of points of the Binomial smoothing. It has to be odd. If not then 1 is added to pts
function binomial(sig,pts)
	pts = pts or 3
	if pts % 2 == 0 then pts = pts + 1 end	-- make it odd
	
	local bco = {}	-- Binomial coefficiencts
	local norm = 4^pts
	for i = 0,pts do
		bco[i] = statData.nCr(2*pts,pts+i)/norm
		bco[-i] = bco[i]
	end
	local fsig = {}	-- Filtered signal
	for i = 1,#sig do
		local as = 0
		for j = -pts,pts do
			if sig[i+j] then
				as = as + sig[i+j]*bco[j]
			end
		end
		fsig[i] = as
	end
	return fsig
end