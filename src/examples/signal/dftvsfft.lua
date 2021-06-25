-- Script to demonstrate signal fourier transform using dft vs fft

require("LuaMath")
fourier = require("signal.fourier")

-- Make a sine wave of frequency 1KHz
sigsine = {}
x = {}

local totSam = 512
local T = 1e-3
local totT = T*5
local Ts = totT/totSam

print("Create a sine wave of frequency "..tostring(1/T).." ("..T.." time period) with 5 periods and "..totSam.." samples total")
for t = 0,totT-Ts,Ts do	-- 10 us step to 5ms (5 periods with 100 samples in each period)
	x[#x + 1] = t
	sigsine[#x] = math.sin(2*math.pi*t/T)
end
print("Plot the wave")
-- Plot the waveform
plot = require("lua-plot")
p1 = plot.plot({})
p1:AddSeries(x,sigsine)

p1:Show()

print("Take the fourier transfor using dft")
-- Now take the fourier transform using dft
print("Time:",os.clock())
fsigsine = fourier.dft(sigsine)
print("Time:",os.clock())
f = {}
fsine = {}
fbin = 1/(Ts*totSam)
for i = 1,#fsigsine do
	f[i] = (i-1)*fbin
	fsine[i] = math.abs(fsigsine[i])
end

-- Now plot the transform

p = plot.plot({})
p:AddSeries(f,fsine)

p:Show()
io.read()

print("Take the fourier transform using fft")
print("Time:",os.clock())
fsigsine = fourier.fft(sigsine)
print("Time:",os.clock())

f = {}
fsine = {}
fbin = 1/(Ts*totSam)
for i = 1,#fsigsine do
	f[i] = (i-1)*fbin
	fsine[i] = math.abs(fsigsine[i])*(2/totSam) --  since totSam samples and half od the spectrum is displayed so adding energy for the other half od the spectrum.
end

-- Now plot the transform

p = plot.plot({})
p:AddSeries(f,fsine)

p:Show()
io.read()
