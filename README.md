LuaMath
=======

Introduction
------------
This is a package to collect, maintain and create functionality to allow the standard latest Lua interpreter and other software that embed Lua to be used as a Mathematical package. It is not limited to just numerical manipulations but also symbolic equation manipulations, plots and anything related. 

Pre-requisites
--------------
- IUP (http://www.tecgraf.puc-rio.br/iup/) should be present in the Lua Path. This package is used for plotting
- llthreads (https://github.com/Neopallium/lua-llthreads) should be present in the Lua Path. This package is used to create a separate thread which runs a plot server

Usage
-----

All code file to use Lua Math should be placed in the root directory and should require LuaMathInit file which adds the proper path and cpath to the lua interpreter paths to find the required modules

References
----------
- Complex numbers (Thanks to library from Philippe Castagliola http://philippe.castagliola.free.fr/LUA/complex.html)
- Basic plotting (Using IUP and help from Steve Donovan's code http://www.tecgraf.puc-rio.br/iup/en/basic/)
