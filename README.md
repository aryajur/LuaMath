LuaMath
=======

Introduction
------------
This is a package to collect, maintain and create functionality to allow the standard latest Lua interpreter and other software that embed Lua to be used as a Mathematical package. It is not limited to just numerical manipulations but also symbolic equation manipulations, plots and anything related. 

Pre-requisites
--------------
- IUP (http://www.tecgraf.puc-rio.br/iup/) should be present in the Lua Path. This package is used for plotting
- luasocket (https://github.com/diegonehab/luasocket) should be present in the Lua Path. This is used to handle communication between the threads.
- llthreads (https://github.com/Neopallium/lua-llthreads) should be present in the Lua Path. This package is used to create a separate thread which runs a plot server
- subModSearcher (https://github.com/aryajur/subModSearcher) should be present in the Lua Path. This package makes finding sub-modules easier.

- All packages inside the clibs are pre-built binaries and should be placed where package.cpath will check for them.

Usage
-----

All code file to use Lua Math should be placed in the root directory and should require LuaMath file which adds the proper path and cpath to the lua interpreter paths to find the required modules

Bode Plot example

```lua
require("LuaMath")
local plot = require "lua-plot" 

function func(s)
	return 1000/((1+s)*(1+s/100))
end

local bp = plot.bodePlot{
	func = func,
	ini = 0.01,
	finfreq = 1000,
	steps = 20
}

bp.mag:Show({title="Magnitude Plot",size="HALFxHALF"})
bp.phase:Show({title="Phase Plot",size="HALFxHALF"})
```

References
----------
- Complex numbers (Thanks to library from Philippe Castagliola http://philippe.castagliola.free.fr/LUA/complex.html)
- Basic plotting (Using IUP and help from Steve Donovan's code http://www.tecgraf.puc-rio.br/iup/en/basic/)
