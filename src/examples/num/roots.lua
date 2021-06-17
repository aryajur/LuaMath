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

print("Cube Roots of 1e20")
print(roots.solvenr(function(x) return x^3-1e20 end,1e10,1e-6))

require("complex")
print("Complex roots of 4th degree polynomial: 5*x^4 - 4*x^2 + 2*x -3")
function f2(x) return 5*x^4 - 4*x^2 + 2*x -3 end
print(roots.solvenr(f2,2,1e-6))
print(roots.solvenr(f2,math.i,1e-6))
print(roots.solvenr(f2,-math.i,1e-6))

print("Complex roots of 2nd degree polynomial: x^2-4*x+13 -> 2+3i,2-3i")
function f3(x) return x^2-4*x+13 end
print(roots.solvenr(f3,2,1e-6))
print(roots.solvenr(f3,math.i,1e-6))
print(roots.solvenr(f3,-math.i,1e-6))
