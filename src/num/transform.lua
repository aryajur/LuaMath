-- Module to transform numbers into different forms

local modname = ...

local M = {}
package.loaded[modname] = M
if setfenv then
	setfenv(1,M)
else
	_ENV = M
end


-- Function to transform a integral part of a number to binary
function toBinary(num,binchar0,binchar1)
    local NUM = num//1  -- Convert to integral value
	binchar0 = binchar0 or "0"
	binchar1 = binchar1 or "1"
    local bin = ""
	if NUM == 0 then return binchar0 end
    while NUM//2 ~= 0 do
        bin = (NUM%2==1 and binchar1 or binchar0)..bin
        NUM = NUM//2
    end
    return binchar1..bin
end