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

_VERSION = "1.21.06.25"

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
	for k = 1,fin do
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
	for k = 1,fin do
		local sum = 0
		for n = 1,N do
			sum = sum + sig[n]*math.exp(fac*(k-1)*tsam[n])
		end
		Xk[k] = sum*fac1
	end
	return Xk,2*math*pi/T
end

-- FFT Algorithm from https://rosettacode.org/wiki/Fast_Fourier_transform#Lua
-- Cooley–Tukey FFT (in-place, divide-and-conquer)
-- Higher memory requirements and redundancy although more intuitive
local function ffti(vect)
	local n=#vect
	if n<=1 then return vect end
	-- divide  
	local odd,even={},{}
	for i=1,n,2 do
		odd[#odd+1]=vect[i]
		even[#even+1]=vect[i+1]
	end
	-- conquer
	ffti(even);
	ffti(odd);
	-- combine
	for k=1,n/2 do
		local t=even[k] * math.exp(-2*math.i*math.pi*(k-1)/n)
		vect[k] = odd[k] + t;
		vect[k+n/2] = odd[k] - t;
	end
	return vect
end

-- ffti wrapper function to adjust the size of the vector to be power of 2
-- fft works cleanest when vector is power of 2. So the rest of the extra space is padded with 0s
-- This makes the number of samples more so the mirror spectrum position incorrect
-- So in the end the spectrum is truncated to half of the original vector length to return only one
-- half of the spectrum which is the correct result.
function fft(vect)
	-- Check if vect length is power of 2
	local n = #vect
	if n == 1 then return nil,"Need a array of length > 1" end
	local len = 2
	while len < n do
		len = len*2
	end
	local newvect = vect
	if len > n then
		newvect = {}
		table.move(vect,1,n,1,newvect)
		for i = n+1,len do
			newvect[i] = 0
		end
	end
	local vfft = ffti(newvect)
	-- Take only half the spectrum
	
	return table.move(vfft,1,n/2%1==0 and n/2 or (n+1)/2,1,{})
end