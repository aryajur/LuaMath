-- Module to provide path discretization


local modname = ...
local math = require("math")
local type = type
local tostring = tostring

local M = {}
package.loaded[modname] = M
if setfenv then
	setfenv(1,M)
else
	_ENV = M
end

-- alphaD is in degrees
-- return 2 tables and the coordinates of the end center point
-- rects - containing definition of all rectangles
--	* w = width of the rectangle, perpendicular to the line joining the 2 end points
--	* n1 = 1st node name. Located at the mid point of the 1st width side
--  * n2 = 2nd node name. Located at the mid point of the 2nd width side
-- nodes - containing coordinates of all nodes indexed by node names
--  * x,y = coordinates of the node

-- endBridge - if true then the bridge at the very end of the segment is also created. It ovehangs the segment by W1/(2*nw)
function discreteRect(L1,W1,alphaD,nw,nl,endBridge)
	if type(L1) ~= "number" or type(L1) ~= "number" or type(L1) ~= "number" or type(L1) ~= "number" or type(L1) ~= "number" then
		return nil,"Need numbers for L1,W1,alpha,nw,nl"
	end
	local rects = {}
	local nodes = {}
	local lh,wh,lv,wv
	lh = L1/nl
--	wh = W1/(nw+1)
	wh = W1/nw
	lv = wh
--	wv = lh		--  might want to change it based on response to Fast Henry forum question about segment overlaps
--	wv = lh/2		--  might want to change it based on response to Fast Henry forum question about segment overlaps
	wv = wh

	local alpha = math.pi/180*alphaD
	local ca = math.cos(alpha)
	local sa = math.sin(alpha)
	
	for i = 1,nl do
	--[[
		rects[#rects + 1] = {
--			l = lh,
			w = wh,
			n1 = "S"..tostring(i-1).."_1",
			n2 = "S"..tostring(i).."_1",
		}
		nodes["S"..tostring(i-1).."_1"] = {
			x = L1/nl*(i-1)*ca+W1/2*sa-W1/(2*nw)*sa,
			y = L1/nl*(i-1)*sa-W1/2*ca+W1/(2*nw)*ca,
		}
		nodes["S"..tostring(i).."_1"] = {
			x = L1/nl*i*ca+W1/2*sa-W1/(2*nw)*sa,
			y = L1/nl*i*sa-W1/2*ca+W1/(2*nw)*ca,
		}]]
		for j = 1,nw do
			-- Segment along length
			rects[#rects + 1] = {
--				l = lh,
				w = wh,
				n1 = "S"..tostring(i-1).."_"..tostring(j),
				n2 = "S"..tostring(i).."_"..tostring(j),
			}
			nodes["S"..tostring(i-1).."_"..tostring(j)] = {
				x = L1/nl*(i-1)*ca+W1/2*sa-W1/(2*nw)*(2*j-1)*sa,
				y = L1/nl*(i-1)*sa-W1/2*ca+W1/(2*nw)*(2*j-1)*ca,
			}
			nodes["S"..tostring(i).."_"..tostring(j)] = {
				x = L1/nl*i*ca+W1/2*sa-W1/(2*nw)*(2*j-1)*sa,
				y = L1/nl*i*sa-W1/2*ca+W1/(2*nw)*(2*j-1)*ca,
			}
			if (i ~= nl or (i == nl and endBridge)) and j ~= 1 then
				-- Segment along width  to connect to the last segment along length
				rects[#rects + 1] = {
--					l = lh,
					w = wv,
					n1 = "S"..tostring(i).."_"..tostring(j-1),
					n2 = "S"..tostring(i).."_"..tostring(j),
				}
			end
		end
	end
	-- Also calculate and return the end node
	return rects,nodes,L1*ca,L1*sa
end

-- Function to discretize a bend
-- See the derivation
-- n is the number of segments along the width
-- NOTE: This is a 2D function. L1, W1, L2, W2 should be dimensions which lie in a plane or their projections on a plane and z should be handled separately
-- Nodes of bend are N1_(1 to n), N2_(1 to n) and N3_(1 to n). N1 is the initial, N2 is the common point at the bend and N3 is the ending. The bridge is made on N2 nodes
function discreteBend(L1,W1,L2,W2,alphaD,thetaD,n,jbridge,endbridge)
	local alpha = math.pi/180*alphaD
	local ca = math.cos(alpha)
	local sa = math.sin(alpha)
	
	local theta = math.pi/180*thetaD
	local ct = math.cos(theta)
	local st = math.sin(theta)
	
	local cat = ca*ct-sa*st	-- Cos(alpha+theta)
	local sat = sa*ct+ca*st	-- Sin(alpha+theta)
	
	local rects = {}
	local nodes = {}
	local ws1 = W1/n
	local ws2 = W2/n
	local wb
	if ws1 < ws2 then
		wb = ws1
	else
		wb = ws2
	end
	
	local A = {x = W1/2*sa, y = -W1/2*ca}  -- lower left corner of the 1st segment  (the one making the angle alpha with x axis)
	local E = {x = -A.x, y = -A.y}	-- Top left corner of the 1st segment
	local B,C,D,F,en
--	if thetaD <= 180 then
		B = {x = A.x+L1*ca, y = A.y+L1*sa}	-- The lower node of the intersection line of the 2 segments
		D = {x = B.x-L2*cat,y = B.y-L2*sat}	-- Lower right corner of the 2nd segment
		F = {x = D.x+W2*sat, y = D.y-W2*cat}
		en = {x = D.x+W2/2*sat, y = D.y-W2/2*cat}
		C = {}
		if math.abs(ca) < 1e-6 then
			-- Slope of line EC (point C is the upper node the of the intersection line of the 2 segments) ~ 90 deg
			C.x = E.x
			C.y = sat/cat*(E.x-F.x)+F.y
		elseif math.abs(cat) < 1e-6 then
			-- Slope of line FC is ~ 90 deg
			C.x = F.x
			C.y = sa/ca*(F.x-E.x)+E.y
		else
			local m1 = sa/ca
			local m2 = sat/cat
			if math.abs(m1-m2) < 1e-6 then
				-- The bend is almost non existent and the thing is straight
				C.x = B.x
				C.y = E.y
			else
				C.x = (F.y-E.y+m1*E.x-m2*F.x)/(m1-m2)
				C.y = (m1*m2*(E.x-F.x)+m1*F.y-m2*E.y)/(m1-m2)
			end
		end
--[[	else
		C = {x = E.x+L1*ca, y = E.y+L1*sa}	
		F = {x = C.x-L2*cat, y = C.y-L2*sat}
		D = {x = F.x-W2*sat,y = F.y+W2*cat}	
		en = {x = F.x-W2/2*sat, y = F.y+W2/2*cat}
		B = {}
		if math.abs(ca) < 1e-6 then
			-- Slope of AB is ~ 90 deg
			B.x = A.x
			B.y = sat/cat*(A.x-D.x)+D.y
		elseif math.abs(cat) < 1e-6 then
			-- Slope of line BD is ~ 90 deg
			B.x = D.x
			B.y = sa/ca*(D.x-A.x)+A.y
		else
			local m1 = sa/ca
			local m2 = sat/cat
			if math.abs(m1-m2) < 1e-6 then
				B.x = C.x
				B.y = A.y
			else
				B.x = (D.y-A.y+m1*A.x-m2*D.x)/(m1-m2)
				B.y = (m1*m2*(A.x-D.x)+m1*D.y-m2*A.y)/(m1-m2)
			end
		end
	end		-- if thetaD <= 180 then ends]]
	-- Length BC
	local BC = math.sqrt((C.y-B.y)^2+(C.x-B.x)^2)
	local angleBC = math.atan(C.y-B.y,C.x-B.x)
	-- Now setup the rects and the nodes
	for i = 1,n do
		-- For each iteration we create 2 discretized segments in each segment
		-- We also create a segment bridge from the current junction to the previous loop discretized segment junction
		
		-- 1st get the 3 nodes
		local N1i = {x = A.x-ws1/2*(2*i-1)*sa, y = A.y+ws1/2*(2*i-1)*ca}
		local N2i = {x = B.x+BC/(2*n)*(2*i-1)*math.cos(angleBC), y = B.y+BC/(2*n)*(2*i-1)*math.sin(angleBC)}
		local N3i = {x = D.x+ws2/2*(2*i-1)*sat, y = D.y-ws2/2*(2*i-1)*cat}
		rects[#rects + 1] = {
			w = ws1,
			n1 = "N1_"..tostring(i),
			n2 = "N2_"..tostring(i)
		}
		rects[#rects + 1] = {
			w = ws2,
			n1 = "N2_"..tostring(i),
			n2 = "N3_"..tostring(i)
		}
		-- Junction bridge
		if i > 1 and jbridge then
			rects[#rects + 1] = {
				w = wb,
				n1 = "N2_"..tostring(i-1),
				n2 = "N2_"..tostring(i)
			}
		end	
		-- End bridge
		if i > 1 and endbridge then
			rects[#rects + 1] = {
				w = wb,
				n1 = "N3_"..tostring(i-1),
				n2 = "N3_"..tostring(i)
			}
		end
		nodes["N1_"..tostring(i)] = N1i
		nodes["N2_"..tostring(i)] = N2i
		nodes["N3_"..tostring(i)] = N3i
	end
	return rects, nodes,en.x,en.y, B.x+BC/2*math.cos(angleBC), B.y+BC/2*math.sin(angleBC)
end

function discreteSplit(L1,W1,L2,W2,L3,W3,alpha,theta1,theta2,n)
	
end