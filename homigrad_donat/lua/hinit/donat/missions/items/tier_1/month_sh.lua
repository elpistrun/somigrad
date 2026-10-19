--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_donat/lua/hinit/donat/missions/items/tier_1/month_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:13
addons/homigrad_core/lua/shlib/tier_0/sh_event.lua:83
addons/homigrad_core/lua/shlib/loader.lua:206
lua/includes/modules/hook.lua:102 <
]]

-- "addons\\homigrad_donat\\lua\\hinit\\donat\\missions\\items\\tier_1\\month_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local Mission = MissionItem_Reg("month","day")
if not Mission then return end

Mission.raryType = "legendary"
Mission.ResetTime = 60 * 60 * 24 * 30 - 6 * 60 * 60 * 6
Mission.Category = "mission_category_3"

Mission.Config = {
    {
        name = "donat_mission_month1",
        max = 25000,
        PlayerDamageTo = function(self,ply,dmgTab)
            if ply == self.ownerPly then return end

            self:AddWriteProgress(math.Round(dmgTab.dmg))
        end
    },
    {
        name = "donat_mission_month2",
        desc = "donat_mission_month2_desc",
        max = 100,
        PlayerDeath = function(self,ply,dmgTab)
            self:AddWriteProgress(1)
        end
    },
    {
        name = "donat_mission_month3",
        desc = "donat_mission_month3_desc",
        PlayerKill = function(self,ply,dmgTab)
            if self.max and ply != dmgTab.att and not ply.roleT then
                self:AddProgress(1)
            end
        end,
        RoundStart = function(self)
            self:SetProgress(0)

            self:SetMax(#player.GetAll() > 20 and self.ownerPly.roleT and (#PlayersInGame() - #traitors) * 0.6 or false)
        end
    },
    {
        name = "donat_mission_month4",
        desc = "donat_mission_month4_desc",
        PlayerKill = function(self,ply,dmgTab)
            if self.max and ply != dmgTab.att and not ply.roleT then
                self:SetMax(false)
            end
        end,
        PlayerDeath = function(self)
            self:SetMax(false)
        end,
        RoundStart = function(self)
            self:SetMax(#player.GetAll() > 20 and self.ownerPly.roleT and 1 or false)
        end,
        RoundEnd = function(self)
            if self.max then self:WriteCanComplete() end
        end
    }
}
