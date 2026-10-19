--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgame/tier_2_entities/granade/tier_1_content/flashbang_explosive_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:4 <
]]

-- "addons\\homigrad\\lua\\hgame\\tier_2_entities\\granade\\tier_1_content\\flashbang_explosive_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local EXP = oop.Reg("explosive_flashbang","explosive_base")
if not EXP then return end

EXP.FragCount = false
EXP.Power = 0

EXP.RadiusDamage = 750
EXP.RadiusStun = 750

EXP.KeepExplosiveParent = 3

local Safe = {
    ["GasMask"] = true
}

if CLIENT then
    local flashbang = 0

    function EXP:Emit()
        sound.Emit(nil,"arccw_go/flashbang/flashbang_explode1.wav",90,1,100,self.pos)
        if self.isGround then self:EmitSpoon() end

        local dlight = DynamicLight(self.parent:EntIndex())
        if dlight then
            dlight.pos = self.pos
            dlight.r = 255
            dlight.g = 255
            dlight.b = 255
            dlight.brightness = 3
            dlight.decay = 1000
            dlight.size = self.RadiusStun
            dlight.dietime = CurTime() + 1
        end

        for i,armor in pairs(LocalPlayer().Armors) do
            if Safe[armor.name] and not armor.tgl then return end
        end

        local pos,ang = LocalPlayer():Eye()

        local k = 1 - self.pos:Distance(pos) / self.RadiusStun

        if k > 0 and sound.GetDSP(self.pos,{
            [LocalPlayer()] = true,
            [self.parent] = true
        },pos) == DSP_LEVEL0 then
            GiveEarrape(0.25)

            if (self.pos - pos):GetNormalized():Dot(Vector(1,0,0):Rotate(ang)) >= 0.25 then
                flashbang = 10 * math.Clamp(k,0,1)
            end
        end
    end

    hook.Add("PostDrawHUD","Flashbang",function()
        if not LocalPlayer():Alive() then flashbang = 0 return end

        surface.SetDrawColor(255,255,255,255 * math.min(flashbang,1))
        surface.DrawRect(0,0,ScrW(),ScrH())

        flashbang = math.max(flashbang - FrameTime(),0)
    end)
else
    function EXP:Attack(dmgTab)
        local target = dmgTab.target
        if not target:IsPlayer() then return end

        for i,armor in pairs(target.Armors) do
            if Safe[armor.name] and not armor.tgl then return end
        end

        local pain = 10

        local pos,ang = target:Eye()
        if (self.pos - pos):GetNormalized():Dot(Vector(1,0,0):Rotate(ang)) >= 0.25 then
            pain = pain + 25
        end

        dmgTab.noCalculateArmor = true
        dmgTab.fakeDown = true

        dmgTab.dmg = 0
        dmgTab.giveGuilt = 100
        dmgTab.pain = pain
        dmgTab.impulse = 16

        target:TakeDamageTab(dmgTab)
    end
end
