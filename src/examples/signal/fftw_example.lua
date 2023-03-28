-- Script to demonstrate signal fourier transform using fft

require("LuaMath")
fourier = require("signal.fourier")

-- Make a sine wave of frequency 1KHz
sigsine = {}
x = {}
Ts=100e-6
--totSam = 2140	-- To show spectral leakage since not integral multiple of period
totSam = 2000

print("Create a sine wave of frequency 50Hz with 5 periods and 100 samples in each period")
for t = 0,totSam-1 do	
	x[#x + 1] = t*Ts
	sigsine[#x] = math.sin(2*math.pi*50*t*Ts)
end
print("Plot the wave")
print("Total samples=",#x)
-- Plot the waveform
plot = require("lua-plot")
p1 = plot.plot({})
p1:AddSeries(x,sigsine)

p1:Show()

print("Take the fourier transfor for it.")
-- Now take the fourier transform using dft
print("Time:",os.clock())
fsigsine = fourier.fftw(sigsine)
print("Time:",os.clock())
f = {}
fsine = {}
fbin = 1/(Ts*(#sigsine))
for i = 1,#fsigsine do
	f[i] = (i-1)*fbin
	fsine[i] = math.abs(fsigsine[i])*(2/#sigsine)
end

-- Now plot the transform

p = plot.plot({})
p:AddSeries(f,fsine)

p:Show()
io.read()
