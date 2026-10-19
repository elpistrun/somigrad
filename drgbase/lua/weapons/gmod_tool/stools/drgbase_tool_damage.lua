--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/drgbase/lua/weapons/gmod_tool/stools/drgbase_tool_damage.lua <
    > Callstack: gamemodes/sandbox/entities/weapons/gmod_tool/stool.lua:159
[C]:-1
gamemodes/sandbox/entities/weapons/gmod_tool/shared.lua:390
[C]:-1
gamemodes/sandbox/entities/weapons/gmod_tool/cl_init.lua:11 <
]]

TOOL.Tab = "DrGBase"
TOOL.Category = "Tools"
TOOL.Name = "#tool.drgbase_tool_damage.name"
TOOL.ClientConVar = {
	["value"] = 0,
	["type"] = DMG_GENERIC
}
TOOL.BuildCPanel = function(panel)
	GetConVar("drgbase_tool_damage_type"):SetInt(DMG_GENERIC)
	panel:Help("#tool.drgbase_tool_damage.desc")
	panel:NumSlider("Damage", "drgbase_tool_damage_value", 0, 10000)
	local dlist = DrGBase.DListView({"Type", "Enabled"})
	dlist:AddLine("Crush", "False", DMG_CRUSH)
	dlist:AddLine("Slash", "False", DMG_SLASH)
	dlist:AddLine("Blast", "False", DMG_BLAST)
	dlist:AddLine("Burn", "False", DMG_BURN)
	dlist:AddLine("Slow burn", "False", DMG_SLOWBURN)
	dlist:AddLine("Shock", "False", DMG_SHOCK)
	dlist:AddLine("Plasma", "False", DMG_PLASMA)
	dlist:AddLine("Dissolve", "False", DMG_DISSOLVE)
	dlist:AddLine("Sonic", "False", DMG_SONIC)
	dlist:AddLine("Poison", "False", DMG_POISON)
	dlist:AddLine("Acid", "False", DMG_ACID)
	dlist:AddLine("Radiation", "False", DMG_RADIATION)
	dlist:AddLine("Neurotoxin", "False", DMG_NERVEGAS)
	dlist:SetSize(10, 250)
	dlist:SetMultiSelect(false)
	function dlist:OnRowSelected(id, line)
		local type = GetConVar("drgbase_tool_damage_type")
		if line:GetValue(2) == "True" then
			line:SetValue(2, "False")
			type:SetInt(type:GetInt()-line:GetValue(3))
		else
			line:SetValue(2, "True")
			type:SetInt(type:GetInt()+line:GetValue(3))
		end
	end
	panel:AddItem(dlist)
end

function TOOL:LeftClick(tr)
	local ent = tr.Entity
	if IsValid(ent) and SERVER then
		local dmg = DamageInfo()
		dmg:SetDamage(self:GetClientNumber("value"))
		dmg:SetDamageType(self:GetClientNumber("type"))
		dmg:SetAttacker(self:GetOwner())
		dmg:SetInflictor(self:GetOwner():GetActiveWeapon())
		dmg:SetDamageForce(tr.Normal*self:GetClientNumber("value"))
		dmg:SetDamagePosition(tr.HitPos)
		dmg:SetReportedPosition(tr.HitPos)
		ent:DispatchTraceAttack(dmg, tr)
	end
	return true
end
function TOOL:Reload()
	local owner = self:GetOwner()
	return self:LeftClick({
		Normal = -owner:EyeAngles():Forward(),
		Entity = owner, HitPos = owner:GetPos()
	})
end

if CLIENT then
	language.Add("tool.drgbase_tool_damage.name", "Inflict Damage")
	language.Add("tool.drgbase_tool_damage.desc", "Inflict damage to an entity.")
	language.Add("tool.drgbase_tool_damage.0", "Left click to inflict damage.")
end

