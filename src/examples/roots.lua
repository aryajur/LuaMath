require("LuaMath")
roots = require("num.roots")

local function func(x)
	-- (x-1)*(x-3) = x^2-4*x+3
	return x^2-4*x+3
end

print("Roots of the equation are 1 and 3")
print("Root calculation with guess of 0.5:")
print(roots.solvenr(func,0.5,0.0001,1e5))		-- 0.99871278862885        0.0025760796554222
print("Root calculation with guess of 3.5:")
print(roots.solvenr(func,3.5,0.0001,1e5))		-- 3.0871969614022 			0.18199723288209