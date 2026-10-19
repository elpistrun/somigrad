--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgamemode/spawnmenu_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:8 <
]]

-- "addons\\homigrad\\lua\\hgamemode\\spawnmenu_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
AdminPanelSuccessReg("spawnmenu_access",nil,"rights")

-- The two hooks below are what sandbox's spawnmenu checks before it opens:
--   GM:OnSpawnMenuOpen -> if ( !hook.Call( "SpawnMenuOpen", self ) ) then return end
--   GM:OnContextMenuOpen -> if ( !hook.Call( "ContextMenuOpen", self ) ) then return end
-- The same check is what the engine's +menu / +menu_context run into, so returning a falsy
-- value here means Q and C do nothing at all -- not an empty menu, nothing.
--
-- And that is exactly what happened: this gate answers through
-- HasSuccess("spawnmenu_access"), which needs AdminPanelRoles + Profiles. Both arrive over
-- server net messages whose server half is not part of this pack, so HasSuccess is false
-- for every player forever and the spawn menu and context menu were unreachable for
-- everyone, admin or not. Fall back to what the engine itself knows about the player
-- rather than bricking the menus when the role system cannot answer.
local adminGroups = {
    ["root"] = true,
    ["superadmin"] = true,
    ["dsuperadmin"] = true,
    ["admin"] = true,
    ["dadmin"] = true,
    ["operator"] = true,
    ["doperator"] = true,
    ["owner"] = true,
    ["founder"] = true,
    ["headadmin"] = true,
    ["moderator"] = true,
    ["curator"] = true
}

local function CanUseMenu(ply)
    if not IsValid(ply) then return false end

    local grp = string.lower(ply:GetUserGroup() or ply:GetNWString("UserGroup", "") or "")
    if adminGroups[grp] or ply:IsAdmin() or ply:IsSuperAdmin() then return true end
    if ply:IsListenServerHost() then return true end
    if game.SinglePlayer() and ply == LocalPlayer() then return true end

    if ply.HasSuccess and ply:HasSuccess("spawnmenu_access") then return true end
    if AdminPanelRole_HasSuccess and AdminPanelRole_HasSuccess(ply, "spawnmenu_access") then return true end

    if Profiles and ply:SteamID() and Profiles[ply:SteamID()] then
        local roles = Profiles[ply:SteamID()].roles
        if roles and (roles["root"] or roles["superadmin"] or roles["dsuperadmin"] or roles["admin"] or roles["dadmin"] or roles["operator"] or roles["doperator"]) then
            return true
        end
    end

    // no role table at all (the role backend never answered) -> do not block
    if not AdminPanelRoles or not next(AdminPanelRoles) then return true end

    return false
end

hook.Add("SpawnMenuOpen","hide_spawnmenu",function()
    return CanUseMenu(LocalPlayer())
end)

hook.Add("ContextMenuOpen","hide_spawnmenu",function()
    return CanUseMenu(LocalPlayer())
end)

// kept for the rest of the gamemode, which asks through these events
local function CanUseSpawn(ply) return CanUseMenu(ply) end

event.Add("Can Use Spawn","Admin",CanUseSpawn,10)

event.Add("Can Properties","Admin",CanUseSpawn,10)

hook.Add("OnPhysgunFreeze","ent",function(_,_,ent,ply)
    ent.hold = nil

    if ent.CanPhysgunFreeze then return ent:CanPhysgunFreeze(ply) end
end)

hook.Add("PhysgunPickup","ent",function(ply,ent)
    ent.hold = ply

    if ent.CanPhysgun then return ent:CanPhysgun(ply) end
end)

hook.Add("PhysgunDrop","ent",function(ply,ent)
    ent.hold = nil

    if ent.CanPhysgunDrop then return ent:CanPhysgunDrop(ply) end
end)

properties.Add("ignite",{
	MenuLabel = "#ignite",
	Order = 999,
	MenuIcon = "icon16/fire.png",
	Filter = function(self,ent,ply)
		return CanUseMenu(ply) and not ent:IsOnFire() 
	end,
	Action = function(self,ent)
		self:MsgStart()
			net.WriteEntity( ent )
		self:MsgEnd()
	end,
	Receive = function(self,length,ply)
		local ent = net.ReadEntity()

		if !properties.CanBeTargeted(ent,ply) then return end
		if !self:Filter( ent,ply) then return end

		ent:Ignite(360)
	end 
})

ExplosiveModel = {
    ["models/props_c17/oildrum001_explosive.mdl"] = true,
    ["models/props_junk/gascan001a.mdl"] = true,
    ["models/props_junk/propane_tank001a.mdl"] = true,

    ["models/props_phx/torpedo.mdl"] = true,
    ["models/props_phx/mk-82.mdl"] = true,
    ["models/props_phx/ww2bomb.mdl"] = true,
    ["models/props_phx/oildrum001_explosive.mdl"] = true,
    ["models/props_phx/ball.mdl"] = true,
    ["models/props_phx/amraam.mdl"] = true,
    ["models/props_c17/canister02a.mdl"] = true,
    ["models/props_junk/metalgascan.mdl"] = true,
    ["models/props_c17/canister01a.mdl"] = true,

    ["models/props_junk/propanecanister001a.mdl"] = true,
    ["models/props_junk/PropaneCanister001a.mdl"] = true,
    
    ["models/tadano/fumo/pack/flandere.mdl"] = true,
    ["models/tadano/fumo/pack/cirno.mdl"] = true,
    ["models/tadano/fumo/pack/inu.mdl"] = true,
    ["models/tadano/fumo/pack/reimu.mdl"] = true,
    ["models/tadano/fumo/pack/yuuka.mdl"] = true,
    ["models/tadano/fumo/pack/yuyu.mdl"] = true,
    ["models/tadano/fumo/pack/remilia.mdl"] = true
}

