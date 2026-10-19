--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgamemode/roundsystem/levels/tier_0_base/util/spawn_player_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/tier_1/oop/sh_tier_0_main.lua:117
addons/homigrad_core/lua/shlib/tier_1/oop/sh_tier_0_main.lua:150
addons/homigrad/lua/hgamemode/roundsystem/levels/tier_0_base/tier_0_sh.lua:3
[C]:-1
addons/homigrad_core/lua/shlib/loader.lua:143
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:8 <
]]

-- "addons\\homigrad\\lua\\hgamemode\\roundsystem\\levels\\tier_0_base\\util\\spawn_player_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local Level = oop.Get("level_base")
if not Level then return end

function Level.GetArmor(armor,col)
	if TypeID(armor) == TYPE_TABLE then
		if not IsColor(armor[2]) then--pizdes cring
			armor = armor[math.random(1,#armor)]
			
			if TypeID(armor) == TYPE_TABLE then
				if not IsColor(armor[2]) then
					armor = armor[math.random(1,#armor)]

					col = armor[2]
					armor = armor[1]
				else
					col = armor[2]
					armor = armor[1]
				end
			end
		else
			col = armor[2]
			armor = armor[1]
		end
	end

	return armor,col
end

function Level.GetModel(model)
	local model = model[math.random(1,#model)]
	local bodygroup = {}
	local force

	if TypeID(model) == TYPE_TABLE then
		for i,value in pairs(model[2] or {}) do
			bodygroup[i] = (TypeID(value) == TYPE_TABLE and math.random(value[1],value[2])) or value
		end

		model = model[1]
		force = model[3]
	end

	return model,bodygroup,force
end

if not SERVER then return end

-- В паке `empty` нигде не присваивается, то есть это nil: оригинальный код вроде
-- `team.weapons or empty` в списках без оружия отдавал в pairs() именно nil.
local empty = {}

util.AddNetworkString("select_class")

net.Receive("select_class", function(len, ply)
	if not IsValid(ply) then return end
	local tab = net.ReadTable()
	if not istable(tab) then return end
	ply.hgClassSettings = tab
end)

function Level.GiveSwep(self, ply, weaponOrList)
	if not IsValid(ply) then return end

	local name
	if isstring(weaponOrList) then
		name = weaponOrList
	elseif istable(weaponOrList) then
		name = weaponOrList[1]
	end
	if not name then return end

	local wep = ply:Give(name)
	if not IsValid(wep) then wep = ply:GetWeapon(name) end

	if IsValid(wep) and wep.Primary and wep.Primary.Ammo and wep.Primary.Ammo ~= "none" and wep.Primary.ClipSize and wep.Primary.ClipSize > 0 then
		ply:GiveAmmo(wep.Primary.ClipSize * 2, wep.Primary.Ammo, true)
	end

	return wep
end

// Всё, что команда (или её класс) объявляет, выдаётся одному игроку по его выбору в меню Классы.
function Level:GiveGear(ply, teamID)
	if not IsValid(ply) or not ply:Alive() then return end
	if not self.GetTeamTable then return end

	local team = self:GetTeamTable(teamID or ply:Team())
	if not team then return end

	-- Ищем сохранённые настройки игрока для текущего режима
	local levelSettings
	local s = ply.hgClassSettings
	if istable(s) then
		if roundActiveName and istable(s[roundActiveName]) then
			levelSettings = s[roundActiveName]
		elseif self.name and istable(s[self.name]) then
			levelSettings = s[self.name]
		else
			for k, v in pairs(Levels) do
				if v == self and istable(s[k]) then
					levelSettings = s[k]
					break
				end
			end
		end
	end

	-- Название команды в teamEncoder
	local teamEncoder = self.teamEncoder
	local teamKey
	local teamNum = teamID or ply:Team()
	if teamEncoder then
		teamKey = teamEncoder[teamNum]
	end
	if not teamKey then
		for k, v in pairs(self) do
			if v == team and isstring(k) then
				teamKey = k
				break
			end
		end
	end

	local teamSettings = levelSettings and teamKey and levelSettings[teamKey]

	local classIndex = teamSettings and tonumber(teamSettings.select)
	local class
	if classIndex and istable(team.classes) and team.classes[classIndex] then
		class = team.classes[classIndex]
	elseif istable(team.classes) and #team.classes > 0 then
		classIndex = 1
		class = team.classes[1]
	end

	local className = istable(class) and class[1] or class

	ply.hgLevelClass = className
	ply.hgGearGiven = true

	// Прежняя броня снимается
	if istable(ply.Armors) and table.Count(ply.Armors) > 0 then
		ply.Armors = {}
		if ply.SetNWTable then ply:SetNWTable("Armor",ply.Armors) end
	end

	local col = istable(team[2]) and team[2] or nil

	local models = (class and class.models) or team.models
	if istable(models) and #models > 0 then
		local mdl,bodygroups = self.GetModel(models)

		if mdl then
			ply:SetModel(mdl)

			for i,bg in pairs(bodygroups or {}) do
				ply:SetBodygroup(i,bg)
			end
		end
	end

	if col then ply:SetPlayerColor(col:ToVector()) end

	for _,name in pairs((class and class.weapons) or team.weapons or empty) do
		ply:Give(name)
	end

	-- Выдача основного оружия по выбору игрока
	local mainWeaponList = (class and class.main_weapon) or team.main_weapon
	local chosenMainWep
	if istable(mainWeaponList) and #mainWeaponList > 0 then
		local classSettings = teamSettings and classIndex and teamSettings[classIndex]
		local mainIdx = classSettings and tonumber(classSettings.main_weapon)
		if mainIdx and mainWeaponList[mainIdx] then
			chosenMainWep = mainWeaponList[mainIdx]
		else
			chosenMainWep = mainWeaponList[1]
		end
	end

	if chosenMainWep then
		self.GiveSwep(self, ply, chosenMainWep)
	elseif mainWeaponList then
		self.GiveSwep(self, ply, mainWeaponList)
	end

	-- Выдача вторичного оружия по выбору игрока
	local secWeaponList = (class and class.secondary_weapon) or team.secondary_weapon
	local chosenSecWep
	if istable(secWeaponList) and #secWeaponList > 0 then
		local classSettings = teamSettings and classIndex and teamSettings[classIndex]
		local secIdx = classSettings and tonumber(classSettings.secondary_weapon)
		if secIdx and secWeaponList[secIdx] then
			chosenSecWep = secWeaponList[secIdx]
		else
			chosenSecWep = secWeaponList[1]
		end
	end

	if chosenSecWep then
		self.GiveSwep(self, ply, chosenSecWep)
	elseif secWeaponList then
		self.GiveSwep(self, ply, secWeaponList)
	end

	for _,armor in pairs((class and class.armors) or team.armors or empty) do
		local armorName,armorCol = self.GetArmor(armor,col)

		Armor_Equip(ply,armorName,armorCol or col)
	end
end

// Level:Start() зовёт это на сервере сразу за StartServer(), и метода не было вовсе --
// старт раунда умирал на "attempt to call method 'SetupFMTeams'". Здесь создаются FM-команды,
// которые объявляет уровень, и выдаётся снаряжение тем, кто уже в игре.
function Level:SetupFMTeams()
	local encoder = self.teamEncoder
	if not encoder then return end

	for id,name in pairs(encoder) do
		local tab = self[name]

		if istable(tab) then
			team.SetUp(id,tab[1],istable(tab[2]) and tab[2] or nil)
		end
	end

	for _,ply in ipairs(PlayersInGame()) do
		if not ply:Alive() then continue end

		self:GiveGear(ply,ply:Team())
	end
end

-- Респавн после смерти: снаряжение выдаётся заново (иначе после первого же трупа игрок
-- остаётся голым, потому что уровень выдаёт его только на старте раунда).
hook.Add("PlayerDeath","HG Level Loadout",function(ply) ply.hgGearGiven = nil end)

local function GiveLevelGear(ply)
	if not IsValid(ply) or not ply:Alive() or ply.hgGearGiven then return end

	local level = TableLevel()

	if not level or not level.GiveGear then return end

	level:GiveGear(ply,ply:Team())
end

hook.Add("PlayerSpawn","HG Level Loadout",function(ply)
	// Команду назначают позже входа в раунд, поэтому выдача с задержкой и один раз на жизнь.
	timer.Simple(0.25,function() GiveLevelGear(ply) end)

	-- Контрольная попытка: если команда пришла позже, чем первый тик, игрок всё равно
	-- должен получить снаряжение. hgGearGiven делает её безопасной -- повторно не выдаст.
	timer.Simple(4,function() GiveLevelGear(ply) end)
end)

-- Смена команды (вход в раунд, выбор стороны в табло) -- тот же вход в снаряжение.
hook.Add("OnTeamChanged","HG Level Loadout",function(ply)
	timer.Simple(0.25,function() GiveLevelGear(ply) end)
end)
