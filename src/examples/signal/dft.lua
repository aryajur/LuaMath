-- Script to demonstrate signal fourier transform using dft

require("LuaMath")
fourier = require("signal.fourier")

-- Make a sine wave of frequency 1KHz
sigsine = {}
x = {}

print("Create a sine wave of frequency 1KHz with 5 periods and 100 samples in each period")
for t = 0,5e-3,10e-6 do	-- 10 us step to 5ms (5 periods with 100 samples in each period)
	x[#x + 1] = t
	sigsine[#x] = math.sin(2*math.pi*1e3*t)
end
print("Plot the wave")
-- Plot the waveform
plot = require("lua-plot")
p1 = plot.plot({})
p1:AddSeries(x,sigsine)

p1:Show()

print("Take the fourier transfor for it.")
-- Now take the fourier transform using dft
print("Time:",os.clock())
fsigsine = fourier.dft(sigsine)
print("Time:",os.clock())
f = {}
fsine = {}
fbin = 1/(10e-6*500)
for i = 1,#fsigsine do
	f[i] = (i-1)*fbin
	fsine[i] = math.abs(fsigsine[i])
end

-- Now plot the transform

p = plot.plot({})
p:AddSeries(f,fsine)

p:Show()
io.read()

-- Now lets do 2 sinusoids

-- Make a sine wave of frequency 1KHz
sigsine = {}
x = {}

print("Create a sine wave of frequency 1KHz,5KHz with 5ms duration 10us sampling time")
for t = 0,5e-3,10e-6 do	-- 10 us step to 5ms (5 periods with 100 samples in each period)
	x[#x + 1] = t
	sigsine[#x] = math.sin(2*math.pi*1e3*t)+2*math.sin(2*math.pi*5e3*t)
end
print("Plot the wave")
-- Plot the waveform

p1 = plot.plot({})
p1:AddSeries(x,sigsine)

p1:Show()

print("Take the fourier transfor for it.")
-- Now take the fourier transform using dft
fsigsine = fourier.dft(sigsine)
f = {}
fsine = {}
fbin = 1/(10e-6*500)
for i = 1,#fsigsine do
	f[i] = (i-1)*fbin
	fsine[i] = math.abs(fsigsine[i])
end

-- Now plot the transform

p = plot.plot({})
p:AddSeries(f,fsine)

p:Show()
io.read()

-- Now try a square Wave
-- Make a square wave signal
sigsq = {}
x = {}
for i = 1,5 do
	for j = 1,50 do
		sigsq[#sigsq + 1] = 1
		x[#x + 1] = (#x-1)*10e-6
	end
	for k = 1,50 do
		sigsq[#sigsq + 1] = -1
		x[#x + 1] = (#x-1)*10e-6
	end
end

print("Plot the wave")
-- Plot the waveform

p1 = plot.plot({})
p1:AddSeries(x,sigsq)

p1:Show()

print("Take the fourier transfor for it.")
-- Now take the fourier transform using dft
fsigsq = fourier.dft(sigsq)
f = {}
fssq = {}
fbin = 1/(10e-6*500)
for i = 1,#fsigsq do
	f[i] = (i-1)*fbin
	fssq[i] = math.abs(fsigsq[i])
end

-- Now plot the transform

p = plot.plot({})
p:AddSeries(f,fssq)

p:Show()
io.read()




