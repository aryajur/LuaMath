-- The following example is taken from the example in the luafft repository at: https://github.com/h4rm/luafft/blob/master/examples/example1.lua
require("LuaMath")
luafft = require "signal.luafft"

local signal = {}
local size = luafft.next_possible_size(2*2048+1)
local frequency = 1024
local length = size / frequency

--size = next_size(size)

--Populates a list with random real numbers in complex format
function populate(list)
  for i=1,size do
	  list[i] = math.sin(2* i/frequency * 2*math.pi) + math.sin(10* i/frequency * 2*math.pi)+ 0*math.i
  end
end

--displays the fourier spectrum
function display(spectrum)
	for i=1,#spectrum/2 do 
		print(string.format("%.1f Hz\t%1.1f",(i-1)/length, (spectrum[i]:abs())))
	end
end

--displays a single list with whatever it contains
function print_list(list)
  for i,v in ipairs(list) do print(i,v) end
end

--devide a list with a certain constant factor
function devide(list, factor)
  for i,v in ipairs(list) do list[i] = list[i] / factor end
end


--create a signal with two sine waves
populate(signal)

--carry out fast fourier transformation and store result in "spec"
local spec = luafft.fft(signal, false)
print("#spec="..#spec)

--now carry out inverse fast fourier transformation and store result in "reconstructed"
reconstructed = luafft.fft(spec, true)

--After retransformation, we need to devide by the data size
devide(reconstructed, size)
devide(spec, size/2)

--Displays the fourier spectrum of the audio signal
display(spec)