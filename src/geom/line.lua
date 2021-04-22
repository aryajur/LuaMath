-- Module to provide function for lines and line segments

local math = math

local max = math.max
local min = math.min

local M = {}
package.loaded[...] = M
if setfenv then
	setfenv(1,M)
else
	_ENV = M
end

-- Reference https://www.geeksforgeeks.org/check-if-two-given-line-segments-intersect/
-- Given three colinear points p, q, r, the function checks if 
-- point q lies on line segment 'pr' 
function onSegment(p, q, r) 
    if (q.x <= max(p.x, r.x) and q.x >= min(p.x, r.x) and
        q.y <= max(p.y, r.y) and q.y >= min(p.y, r.y)) then
       return true
	end
    return false
end 

-- Reference https://www.geeksforgeeks.org/check-if-two-given-line-segments-intersect/
-- To find orientation of ordered triplet (p, q, r). 
-- The function returns following values 
-- 0 --> p, q and r are colinear 
-- 1 --> Clockwise 
-- 2 --> Counterclockwise 
function orientation(p,q,r) 
    -- See https://www.geeksforgeeks.org/orientation-3-ordered-points/ 
    -- for details of below formula. 
    local val = (q.y - p.y) * (r.x - q.x) - (q.x - p.x) * (r.y - q.y)
  
    if val == 0 then return 0 end  -- colinear 
	return (val > 0 and 1) or 2 	-- clock or counterclock wise 
end

-- Reference https://www.geeksforgeeks.org/check-if-two-given-line-segments-intersect/
-- The main function that returns true if line segment 'p1q1' 
-- and 'p2q2' intersect. 
-- Returns 5 if they intersect
-- Returns 1 if p2 lies on p1 q1
-- Returns 2 if q2 lies on p1 q1
-- Returns 3 if p1 lies on p2 q2 
-- Returns 4 if q1 lies on p2 q2
-- Returns false if no intersection
function doIntersect(p1, q1, p2, q2) 
    -- Find the four orientations needed for general and 
    -- special cases 
    local o1 = orientation(p1, q1, p2)
    local o2 = orientation(p1, q1, q2) 
    local o3 = orientation(p2, q2, p1) 
    local o4 = orientation(p2, q2, q1) 
  
    -- Special Cases 
    -- p1, q1 and p2 are colinear and p2 lies on segment p1q1 
    if (o1 == 0 and onSegment(p1, p2, q1)) then return 1 end
  
    -- p1, q1 and q2 are colinear and q2 lies on segment p1q1 
    if (o2 == 0 and onSegment(p1, q2, q1)) then return 2 end 
  
    -- p2, q2 and p1 are colinear and p1 lies on segment p2q2 
    if (o3 == 0 and onSegment(p2, p1, q2)) then return 3 end 
  
    -- p2, q2 and q1 are colinear and q1 lies on segment p2q2 
    if (o4 == 0 and onSegment(p2, q1, q2)) then return 4 end

    -- General case 
    if (o1 ~= o2 and o3 ~= o4) then
        return 5
	end
	  
    return false	-- Doesn't fall in any of the above cases 
end