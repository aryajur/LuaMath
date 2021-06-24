-- Module to implement the Fourier Functions

local modname = ...
local math = require("math")
local table = require("table")
require("complex")
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

-- Discrete Fourier Series calculator
-- NOTE: Discrete fourier Series is for a periodic signal. This assumes the
function dft(sig)
	if type(sig) ~= "table" or #sig==0 then
		return nil,"Signal should be non zero arrays."
	end
	local Xk = {}
	local N = #sig
	local fac = -math.i*2*math.pi/N
	local fin = N/2%1==0 and N/2 or (N+1)/2
	local fac1 = 2/N
	for k = 1,fin+1 do
		local sum = 0
		for n = 1,N do
			sum = sum + sig[n]*math.exp(fac*(k-1)*(n-1))
		end
		Xk[k] = sum*fac1
	end
	return Xk
end

-- Non Uniform Discrete Fourier Series Type 2 Calculator
-- Type 2 is when the time sampling is non-uniform but frequency samples are uniform.
-- The sampling interval is not uniform.
-- Using the formula given at https://en.wikipedia.org/wiki/Non-uniform_discrete_Fourier_transform
-- Also see here for better explanation: https://homepages.inf.ed.ac.uk/rbf/CVonline/LOCAL_COPIES/PIRODDI1/NUFT/node4.html#SECTION00022000000000000000
-- sig is the signal array
-- tsam is the sampling point array for example the time points at which the samples were created
function nudft2(sig,tsam)
	if type(sig) ~= "table" or type(tsam) ~= "table" or #sig==0 then
		return nil,"Signal and sampling points should be non zero arrays."
	end
	if #sig ~= #tsam then
		return nil,"Signal and Sampling Points array should be of the same length."
	end
	local Xk = {}
	local N = #sig
	local T = tsam[#tsam]-tsam[1]
	local fac = -math.i*2*math.pi/T
	local fin = N/2%1==0 and N/2 or (N+1)/2
	local fac1 = 2/N
	for k = 1,fin+1 do
		local sum = 0
		for n = 1,N do
			sum = sum + sig[n]*math.exp(fac*(k-1)*tsam[n])
		end
		Xk[k] = sum*fac1
	end
	return Xk,2*math*pi/T
end