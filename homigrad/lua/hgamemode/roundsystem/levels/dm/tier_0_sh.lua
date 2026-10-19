--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgamemode/roundsystem/levels/dm/tier_0_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:143
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:8 <
]]

-- "addons\\homigrad\\lua\\hgamemode\\roundsystem\\levels\\dm\\tier_0_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local Level = oop.Reg("level_dm","level_base",true)
if not Level then return INCLUDE_BREAK end

Level.ShouldSpawnLoot = true
Level.PropBreakLoot = true
Level:SetEndType("player")

Level.red = {
	"Operator",Color(125,125,125),
	weapons = {"weapon_transmitter","weapon_hands","med_band","med_band","med_kit","med_painkiller","weapon_kabar"},
    classes = {
        {
            "class_solder",
            main_weapon = {"wep_m4a1","wep_ak47","wep_val"}
        },
        {
            "class_scout",
            main_weapon = {"wep_mp7","wep_mp5","wep_mac10"}
        },
        {
            "class_support",
            main_weapon = {"wep_xm1014","wep_neg"}
        }
    },
	secondary_weapon = {"wep_fiveseven","wep_glock","wep_deagl"},
	models = Level.StandardPlayerModels,
    armors = {
        {
            {"ent_jack_gmod_ezarmor_thorcrv",Color(255,255,255)},
            {"ent_jack_gmod_ezarmor_kora_kulon_b",Color(255,255,255)},
            {"ent_jack_gmod_ezarmor_korundvm",Color(255,255,255)}
        },
        {
            {"ent_jack_gmod_ezarmor_pillboxbp",Color(255,255,255)},
            {"ent_jack_gmod_ezarmor_lolkek3f",Color(255,255,255)},
            {"ent_jack_gmod_ezarmor_dufflebag",Color(255,255,255)}
        },
        {
            {"ent_jack_gmod_ezarmor_azimutb",Color(255,255,255)},
            {"ent_jack_gmod_ezarmor_bankrobber",Color(255,255,255)},
            {"ent_jack_gmod_ezarmor_thunderbolt",Color(255,255,255)}
        },
        {
            {"ent_jack_gmod_ezarmor_gascan",Color(255,255,255)},
            {"ent_jack_gmod_ezarmor_aviators",Color(255,255,255)},
            {"ent_jack_gmod_ezarmor_roundglasses",Color(255,255,255)},
            {"ent_jack_gmod_ezarmor_mframe",Color(255,255,255)},
            {"ent_jack_gmod_ezarmor_crossbow",Color(255,255,255)},
        },
        {
            {"ent_jack_gmod_ezarmor_razor",Color(255,255,255)},
            {"ent_jack_gmod_ezarmor_tacticalsport",Color(255,255,255)},
            {"ent_jack_gmod_ezarmor_xcel",Color(255,255,255)},
        },
        {
            {"ent_jack_gmod_ezarmor_bomber",Color(255,255,255)},
            {"ent_jack_gmod_ezarmor_leathercap",Color(255,255,255)},
            {"ent_jack_gmod_ezarmor_kotton",Color(255,255,255)},
            {"ent_jack_gmod_ezarmor_zryachiyhat",Color(255,255,255)},

            {"ent_jack_gmod_ezarmor_smokebalacvlava",Color(255,255,255)},
            {"ent_jack_gmod_ezarmor_zryachiibalacvlava",Color(255,255,255)},
            {"ent_jack_gmod_ezarmor_spookyskull",Color(255,255,255)},
        }
    }
}

Level.teamEncoder = {
	[1] = "red",
}

if SERVER then
    CreateConVar("hg_dm_godtime", "10", FCVAR_ARCHIVE, "Deathmatch pre-round god/prep time in seconds")

    function Level:Start()
        local cvar = GetConVar("hg_dm_godtime")
        local godTime = cvar and cvar:GetInt() or 10
        if godTime <= 0 then
            SetGlobalVar("God Time", 0)
            return
        end

        SetGlobalVar("God Time", CurTime() + godTime)

        timer.Simple(0.1, function()
            for _, ply in ipairs(player.GetAll()) do
                if IsValid(ply) and ply:Alive() then
                    ply:GodEnable()
                end
            end
        end)

        timer.Create("DM_GodTime_End", godTime, 1, function()
            SetGlobalVar("God Time", 0)
            for _, ply in ipairs(player.GetAll()) do
                if IsValid(ply) then
                    ply:GodDisable()
                end
            end
        end)

    end

    function Level:End()
        timer.Remove("DM_GodTime_End")
        SetGlobalVar("God Time", 0)
        for _, ply in ipairs(player.GetAll()) do
            if IsValid(ply) then
                ply:GodDisable()
            end
        end
    end

    hook.Add("PlayerSpawn", "DM_GodTime_Spawn", function(ply)
        if roundActiveName == "level_dm" and GetGlobalVar("God Time", 0) > CurTime() then
            timer.Simple(0, function()
                if IsValid(ply) then
                    ply:GodEnable()
                end
            end)
        end
    end)

    hook.Add("EntityTakeDamage", "DM_GodTime_BlockDamage", function(target, dmginfo)
        if roundActiveName == "level_dm" and GetGlobalVar("God Time", 0) > CurTime() then
            return true
        end
    end)

    hook.Add("StartCommand", "DM_GodTime_BlockAttack", function(ply, ucmd)
        if roundActiveName == "level_dm" and GetGlobalVar("God Time", 0) > CurTime() then
            ucmd:RemoveKey(IN_ATTACK)
            ucmd:RemoveKey(IN_ATTACK2)
        end
    end)

    return
end

function Level:DrawScreen(lply,k)
    local name,color = self:GetTeamName(lply)

    local w,h = ScrW(),ScrH()

    draw.DrawText(L("you",L(lply:GetNWString("ClassName"))),"H.45",w / 2,h / 2,cname,TEXT_ALIGN_CENTER)
 
    draw.DrawText("Death Match","H.45",w / 2,h / 8,cgray,TEXT_ALIGN_CENTER)
    draw.DrawText("Убей всех, останься в живых.","H.25",w / 2,h - h / 8,cgray,TEXT_ALIGN_CENTER)
end

local oldTime
local k = 0

function Level:DrawGodMod()
    local timeLeft = GetGlobalVar("God Time",0) - CurTime()
    if timeLeft <= 0 then
        if oldTime then
            oldTime = nil
        end
        return
    end

    local time = math.ceil(timeLeft)

    if oldTime ~= time then
        oldTime = time

        LocalPlayer():EmitSound("homigrad/vgui/menu_accept.wav",75,100,0.5)

        k = 1
    end

    surface.SetDrawColor(255,255,255,169 * k)

    local x,y = ScrW() / 2,ScrH() * 0.2
    surface.SetFont("HS.45")
    local tw,th = surface.GetTextSize(tostring(time))

    draw.GradientRight(x - tw,y - th / 2,tw,th)
    draw.GradientLeft(x,y - th / 2,tw,th)

    draw.SimpleText(tostring(time),"HS.45",x,y,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

    k = LerpFT(0.25,k,0)
end

function Level:HUDPaint()
    local lply = LocalPlayer()

    self:DrawLoadScreen()
	self:DrawRoundTime()
    self:DrawCenter()
    self:DrawGodMod()
end
