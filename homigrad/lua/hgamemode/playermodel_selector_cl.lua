-- New file (not stolen): restores the open_playermodel_selector concommand.
--
-- Nothing in this install defines it. It is only ever *used*, from two places:
--   * garrysmod/lua/autorun/utilities_menu.lua, which wires it to the button in
--     Utilities -> User -> Player Model
--   * the stock F1 bind
-- so both are dead ends right now. The spawn menu itself does have the tool: the same
-- utilities_menu registers it as the "PlayerModelSelector" tool option, and the spawnmenu
-- module exposes ActivateTool(name), which finds a tool by ItemName and switches the
-- panel over to it. So the command only has to open the menu and then select that tool.

if SERVER then return end

concommand.Add("open_playermodel_selector",function()
	if not spawnmenu or not spawnmenu.ActivateTool then return end

	-- bring the menu up first: ActivateTool only switches a panel inside a menu that is
	-- already alive, and SwitchToolTab throws on a nil g_SpawnMenu.
	-- Wrapped because the gamemode gates opening through its own hooks (hidden spawn
	-- menu for non-admins), and we do not want a dead keybind to throw either way.
	pcall(function()
		if GAMEMODE and GAMEMODE.OnSpawnMenuOpen then
			GAMEMODE:OnSpawnMenuOpen()
		end
	end)

	if not IsValid(g_SpawnMenu) then return end

	pcall(spawnmenu.ActivateTool,"PlayerModelSelector")
end)
