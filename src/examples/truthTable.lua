-- Truth Table expressions

lm = require("LuaMath")
lbool = require("logic.boolean")

tu = require("tableUtils")	-- To pretty print a table (https://github.com/aryajur/tableUtils)
--[[
    bits = 2
    outT = {3,4,12,15}  -- Note #outT=2^bits
    So here we are solving the truth table:
    I1    I0    O3   O2   O1   O0
     0     0     0    0    1    1
     0     1     0    1    0    0 
     1     0     1    1    0    0
     1     1     1    1    1    1
     
    Result returned will be:
    {
        -- For O0
        {"~I0.~I1+I0.I1", "I0.~I1+~I0.I1"}, -- 2nd one is the negated expression
        -- For O1
        {"~I0.~I1+I0.I1", "I0.~I1+~I0.I1"},
        -- For O2
        {"I0.~I1+~I0.I1+I0.I1", "~I0.~I1"},
        -- For O3
        {"~I0.I1+I0.I1", "~I0.~I1+I0.~I1"}
    }
	]]
t = lbool.solveTruthTable(2,{3,4,12,15})

print(tu.t2spp(t))

-- Now lets generate truth tables for the 1st output bit and verify that they are complementary
o1,tt1 = lbool.getTruthTable(t[1][1],2)
print(tt1)
o2,tt2 = lbool.getTruthTable("~("..t[1][2]..")",2)
print(tt2)
print(tt1==tt2)
