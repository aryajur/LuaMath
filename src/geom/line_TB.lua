
require("LuaMath")

require("debugUtil")

ln = require("geom.line")

-- Do not intersect
p1 = {x=1,y=1}
q1 = {x=10,y=1}

p2 = {x=1,y=2}
q2 = {x=10,y=2}

print(ln.doIntersect(p1,q1,p2,q2))

-- Intersect
p1 = {x=10,y=0}
q1 = {x=0,y=10}

p2 = {x=0,y=0}
q2 = {x=10,y=10}

print(ln.doIntersect(p1,q1,p2,q2))

-- Same line equation bur do not intersect
p1 = {x=-5,y=-5}
q1 = {x=0,y=0}

p2 = {x=1,y=1}
q2 = {x=10,y=10}

print(ln.doIntersect(p1,q1,p2,q2))

-- q2 lies on p1 q1 return 2
p1 = {x=1,y=1}
q1 = {x=10,y=1}

p2 = {x=5,y=2}
q2 = {x=5,y=1}

print(ln.doIntersect(p1,q1,p2,q2))

-- p2 lies on p1 q1 return 1
p1 = {x=1,y=1}
q1 = {x=10,y=1}

q2 = {x=5,y=2}
p2 = {x=5,y=1}

print(ln.doIntersect(p1,q1,p2,q2))

-- p1 lies on p2 q2 return 3
p1 = {x=5,y=1}
q1 = {x=10,y=1}

q2 = {x=5,y=2}
p2 = {x=5,y=0}

print(ln.doIntersect(p1,q1,p2,q2))

-- p1 lies on p2 q2 return 4
q1 = {x=5,y=1}
p1 = {x=10,y=1}

q2 = {x=5,y=2}
p2 = {x=5,y=0}

print(ln.doIntersect(p1,q1,p2,q2))
