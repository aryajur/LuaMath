require("LuaMath")

d = require("stat.distribution")

SAMPLES = 100000
BIN = 1
MEAN = 100
SIGMA = 20

-- Make the bins from 0 to 200 of BIN
bins = {}
xvals = {}
for i = 1,200/BIN do
	bins[i] = 0
	xvals[i] = BIN*(i-1)+BIN/2
end

-- Generate a Guassian dataset with mean MEAN and sigma SIGMA 
for i = 1,SAMPLES do
	local x = math.modf(d.gaussRandom(MEAN,SIGMA)/BIN)
	bins[x+1] = bins[x+1]+1
end

-- Now plot it

lp = require("lua-plot")
x = {lp.plot{
	TITLE = "Gaussian Distribution, mean="..MEAN..", sigma="..SIGMA,
	MARGINBOTTOM = 30,
	MARGINTOP = 40,
	MARGINLEFT = 60
}}
for i = 1,#x do
	print(x[i])
end

plot = x[1]

print("ADDSERIES",plot:AddSeries(xvals,bins))
print("ATTRIBUTES",plot:Attributes{
	DS_MODE = "BAR"
})
print("SHOW",plot:Show())

io.read()

