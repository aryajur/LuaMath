require("LuaMath")

c = require("geom.circle")

-- discreteRect returns a table of all the rectangle dimension and center coordinates and the error %
print(c.discreteRect(1,5))	-- table: 00abba78	5.1506471496801
print(c.discreteRect(1,6))	-- table: 00aef788	4.3698977154568

