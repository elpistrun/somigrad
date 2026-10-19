--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_core/lua/shlib/tier_0/math/sh_color.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/shlib.lua:5 <
]]

-- "addons\\homigrad_core\\lua\\shlib\\tier_0\\math\\sh_color.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local COLOR = FindMetaTable("Color")

function COLOR:Clone() return Color(self.r,self.g,self.b,self.a) end

function COLOR:Set(colorTo)
    self.r = colorTo.r
    self.g = colorTo.g
    self.b = colorTo.b
    self.a = colorTo.a

    return self
end

function COLOR:Lerp(from,t)
    self.r = Lerp(t,self.r,from.r)
    self.g = Lerp(t,self.g,from.g)
    self.b = Lerp(t,self.b,from.b)
    self.a = Lerp(t,self.a,from.a)

    return self
end


function COLOR:LerpFT(t,from)
    self.r = LerpFT(t,self.r,from.r)
    self.g = LerpFT(t,self.g,from.g)
    self.b = LerpFT(t,self.b,from.b)
    self.a = LerpFT(t,self.a,from.a)

    return self
end
