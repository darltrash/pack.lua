#!/bin/sh
_=[[
    exec lua "$0" "$@"
]]

-- ./pack.lua: A simple embedded Lua script packer designed for simplicity
-- Find the original here: github.com/darltrash/pack.lua
--
-- Copyright (c) 2021 Nelson "darltrash" Lopez
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy of
-- this software and associated documentation files (the "Software"), to deal in
-- the Software without restriction, including without limitation the rights to
-- use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
-- of the Software, and to permit persons to whom the Software is furnished to do
-- so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.

local log = (function ()
--    ULTRA MINIFIED and slightly modified version of log.lua by rxi (github.com/rxi/log.lua)

--    Copyright (c) 2016 rxi
--
--    Permission is hereby granted, free of charge, to any person obtaining a copy of
--    this software and associated documentation files (the "Software"), to deal in
--    the Software without restriction, including without limitation the rights to
--    use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
--    of the Software, and to permit persons to whom the Software is furnished to do
--    so, subject to the following conditions:
--    
--    The above copyright notice and this permission notice shall be included in all
--    copies or substantial portions of the Software.
--    
--    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
--    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
--    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
--    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
--    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
--    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
--    SOFTWARE.

    local a={_version="0.1.0"}a.usecolor=true;a.outfile=nil;a.level="trace"local b=
    {{name="trace",color="\27[34m"},{name="debug",color="\27[36m"},{name="info",
    color="\27[32m"},{name="warn",color="\27[33m"},{name="error",color="\27[31m"},
    {name="fatal",color="\27[35m"}}local c={}for d,e in ipairs(b)do c[e.name]=d end;
    function a.assert(k,l,...)if k then return k end;a.fatal(l,...)os.exit(1)end;
    for d,g in ipairs(b)do local m=g.name:upper()a[g.name]=function(n,...)if d<c[a.level]
    then return end;local o=tostring(n):format(...)local p=debug.getinfo(2,"n").name;
    if p then p="fn "..p.."()"else p=debug.getinfo(2,"S").source end;local q=p..":"
    ..debug.getinfo(2,"l").currentline;print(string.format("%s[%-6s%s]%s %s: %s",
    a.usecolor and g.color or"",m,os.date("%H:%M:%S"),a.usecolor and"\27[0m"or"",q,o))
    if a.outfile then local r=io.open(a.outfile,"a")local s=string.format(
    "[%-6s%s] %s: %s\n",m,os.date(),q,o)r:write(s)r:close()end end end;return a
end)()

local isUnix = package.config:sub(1,1) == "/"
log.usecolor = isUnix
log.outfile = ".log"

log.assert(isUnix, "We're very sorry, Non-UNIX systems are not supported at the moment :(")

local getFilename = function() -- https://stackoverflow.com/questions/48402876/getting-current-file-name-in-lua/48403164
    local str = debug.getinfo(2, "S").source:sub(2)
    return str:sub(3)
end

log.info("Processing './main.lua'")
local mainFile = log.assert(io.open("main.lua", "r"), "'main.lua' not found!")
local main = mainFile:read("all")
mainFile.close()

math.randomseed(os.time())
local buildLibs = "__build_libs_".. math.random(1, 255) -- Random number added to make sure nothing clashes!
local preloadStr = "__build_preload_"..math.random(1, 255)
local output = [[
local ]] .. buildLibs  .. [[ = {}
local ]] .. preloadStr .. [[ = package.loaded or package.preload

local require = function(what)
    if ]] .. buildLibs .. [[[what] then 
        ]] .. preloadStr ..[[[what] = ]] .. buildLibs ..[[[what]()
    end
    if ]] .. preloadStr ..[[[what] then return ]] .. preloadStr ..[[[what] end
    return require(what)
end

]]

local p = io.popen('find . -type f')
for _file in p:lines() do
    local filePath = _file:sub(3)
    local fileExt = filePath:match("^.+(%..+)$")

    if fileExt  == ".lua"        and
       filePath ~= getFilename() and
       filePath ~= "main.lua"    and
       filePath ~= "output.lua"
    then
        local file = filePath:sub(1, #filePath-4)
        local fileLua = file:gsub("/", "%.")
        log.info("Processing '%s'", filePath)

        local filehandle = log.assert(io.open(filePath, "r"), "Apparently, you dont have enough permissions to read '%s'", filePath)
            output = output .. buildLibs .. "[\""..fileLua.."\"] = (function()\n" .. filehandle:read("all") .. "\nend)\n\n"
        filehandle.close()
    end
end
output = output .. main

log.info("Generating 'output.lua'")
local outputfile = log.assert(io.open("output.lua", "w+"), "Cannot open './output.lua' with write permissions")
outputfile:write(output)
outputfile:close()