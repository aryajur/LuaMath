
require("LuaMath")

require("debugUtil")

p = require("geom.path")
i = require("SVGtools.inkscape")

-- discretize a rectangle at an angle
L1 = 10
W1 = 4
L2 = 10
W2 = 8
alpha = 0	-- in degrees
theta = 180
--rects,nodes = p.discreteRect(L1,W1,alpha,5,4)
rects,nodes = p.discreteBend(L1,W1,L2,W2,alpha,theta,4)

-- Now write these rectangles in a SVG file which we can open in inkscape
irects = {}
-- transform rects to irects to pass to inkscape module
for i = 1,#rects do
	irects[i] = {}
	irects[i].h = rects[i].w
	irects[i].w = math.sqrt((nodes[rects[i].n2].y-nodes[rects[i].n1].y)^2+(nodes[rects[i].n2].x-nodes[rects[i].n1].x)^2)
	local alpha = math.atan((nodes[rects[i].n2].y-nodes[rects[i].n1].y),(nodes[rects[i].n2].x-nodes[rects[i].n1].x))
	irects[i].alpha = alpha*180/math.pi
	irects[i].x = nodes[rects[i].n1].x+rects[i].w/2*math.sin(alpha)
	irects[i].y = nodes[rects[i].n1].y-rects[i].w/2*math.cos(alpha)
end

file = i.SVGfromRects(irects)

f = io.open("Output.svg","w+")
f:write(file)
f:close()