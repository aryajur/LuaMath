-- Module for numerical functions for equation manipulations

local modname = ...
local math = require("math")
local type = type
local print = print

local M = {}
package.loaded[modname] = M
if setfenv then
	setfenv(1,M)
else
	_ENV = M
end

--- To solve the func(x)=0 equations using the false position method http://en.wikipedia.org/wiki/False_position_method
--- ARGS:
--- func = Expects a single dimension function
--- xl = lower root limit
--- xh = higher root limit
--- 		xl and xh must be of opposite signs otherwise the function returns nil and error message
--- e = half of upper bound for relative error [OPT,DEF=abs(xh-xl)/m]
--- m = total number of iterations [OPT,DEF=1e5]
--- RETURNS:
--- function returns final x root and the error residue
function solvefp(func,xl,xh,e,m)
--- --
	if not type(func) == "function" then
		return nil, "First argument needs to be a function to be solved func(x)=0"
	end
	if not type(xl) == "number" or not type(xh) == "number" then
		return nil, "Second and third arguments should be numbers for the lower and upper bound of the root"
	end
	m = m or 100000
	if not type(m) =="number" then
		return nil, "Fifth argument should be a number for number of iterations to run"
	end
	
	e = e or (xh-xl)/m
	if not type(e) =="number" then
		return nil, "Fourth argument should be a number for the relative error"
	end
	local fl = func(xl)
	local fh = func(xh)
	if not fl or not fh then
		return nil, "Function returned nil"
	end
	if fl*fh > 0 then
		return nil, "The root limits should be of opposite signs"
	end
	
	local r,fr
	local side=0
	for i=1,m do
		r = (fl*xh-fh*xl)/(fl-fh)
		if math.abs(xh-xl)<e*math.abs(xh+xl) then
			break
		end
		fr = func(r)
		if fr*fh > 0 then
			--fr and fh have same sign, copy r to xh
			xh = r
			fh = fr
			if side == -1 then
				fl = fl/2
			end
			side = -1
		elseif fl*fr > 0 then
			--fr and fl have same sign, copy r to xl
			xl = r
			fl = fr
			if side == 1 then
				fh = fh/2
			end
			side = 1
		else
			--fr*f_ is very small
			break
		end
	end
	return r,fr
end

--- To solve the func(x)=0 equations using the secant method http://en.wikipedia.org/wiki/Secant_method
--- ARGS:
--- func = Expects a single dimension function
--- xi = initial root guess
--- e = half of upper bound for relative error [OPT,DEF=xi/m]
--- m = total number of iterations [OPT,DEF=1e5]
--- RETURNS
--- function returns final x root and the error residue
function solvesec(func,xi,e,m)
--- --
	if not type(func) == "function" then
		return nil, "First argument needs to be a function to be solved func(x) = 0 "
	end
	if not type(xi) == "number" then
		return nil, "Second argument should be a number as the initial guess solution"
	end
	m = m or 100000
	if not type(m) =="number" then
		return nil, "Fourth argument should be a number for number of iterations to run"
	end
	e = e or xi/m
	if not type(e) =="number" then
		return nil, "Third argument should be a number as the absolute error"
	end
	local fi = func(xi)
	local xin = xi - e
	local err = e
	while math.abs(fi-func(xin)) < math.abs(e) do
		err = 2*err
		xin = xi-err
	end
	local fin = func(xin)
	if not fi or not fin then
		return nil, "Function returned nil"
	end
	if math.abs(fi) <= math.abs(e) then
		return xi,fi
	end
	if math.abs(fin) <= math.abs(e) then
		return xin,fin
	end
	
	local xip,fip
	for i=1,m do
		xip = xi - (fi*(xi-xin))/(fi-fin)
		fip = func(xip)
		if math.abs(fip)<=math.abs(e) then
			return xip,fip
		end
		xin = xi
		fin = fi
		xi = xip
		fi = fip
	end
	return xip,fip
end

--- To solve the func(x)=0 equations using Newton-Raphson method
--- ARGS:
--- func = Expects a single dimension function
--- xi = initial root guess
--- e = absolute error i.e. solution is xs where func(xs)=e [OPT,DEF=xi/m]
--- m = total number of iterations [OPT,DEF=1e3]
--- RETURNS
--- function returns final x root and the error residue
function solvenr(func,xi,e,m)
--- --
	if not type(func) == "function" then
		return nil, "First argument needs to be a function to be solved func(x) = 0 "
	end
	if not type(xi) == "number" then
		return nil, "Second argument should be a number as the initial guess solution"
	end
	m = m or 1000
	if not type(m) =="number" then
		return nil, "Fourth argument should be a number for number of iterations to run"
	end
	e = e or xi/m
	if not type(e) =="number" then
		return nil, "Third argument should be a number as the absolute error"
	end
	-- New implementation from Numerical Methods for Non Linear Engineering Models - Hauser
	local FACT = 1e-6
	local fx,cx
	local x = xi
	local nend = m
	local abs = math.abs
	for i = 1,m do
		local dx = x*FACT
		if dx==0 then 
			dx=FACT -- To protect against zero
		end 
		fx = func(x)
		cx = fx - func(x+dx)
		cx  = fx*dx/cx	-- Correction to x value
		x = x+cx
		dx = abs(cx)+abs(x)
		if dx == 0 or abs(cx/dx) < abs(e) then 
			nend = i
			break
		end
	end
	return x,fx,nend,cx
	--[[
	-- Old implementation
	local fi = func(xi)
	local xin = xi - e
	local err = e
	while math.abs(fi-func(xin)) < math.abs(e) do
		err = 2*err
		xin = xi-err
	end
	local fin = func(xin)
	if not fi or not fin then
		return nil, "Function returned nil"
	end
	if math.abs(fi) <= math.abs(e) then
		return xi,fi
	end
	if math.abs(fin) <= math.abs(e) then
		return xin,fin
	end
	
	local xip,fip
	for i=1,m do
		xip = xi - (fi*(xi-xin))/(fi-fin)
		fip = func(xip)
		if math.abs(fip)<=math.abs(e) then
			return xip,fip
		end
		xi = xip
		fi = fip
		xin = xi - err
		while math.abs(fi-func(xin)) > math.abs(e) do
			err = err/2
			xin = xi-err
		end
		while math.abs(fi-fin) < math.abs(e) do
			err = 2*err
			xin = xi-err
			fin = func(xin)
		end
	end
	return xip,fip
	]]
end