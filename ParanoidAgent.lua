local ParanoidAgent = {
	AimDanger = {},
	AreaDanger = {}, 
	ProjectileDanger = {},
	DeadRingerProximity = 300,
	lastUpdated = nil,
}
--
--DangerLib = nil

if not DangerLib then
	local err, loaded = pcall(require, "DangerLib")
	assert(err, "Dangerlib not found!")
end


function ParanoidAgent.ProximityDanger(explosives, cmd)
	local me = entities:GetLocalPlayer()
	if me:GetPropInt("m_iClass") ~= 8 or me:InCond(4) or me:GetPropInt("m_Shared", "m_bFeignDeathReady") == 1 then return end
	for _, bomb in pairs(explosives) do
		if (bomb:GetAbsOrigin() - me:GetAbsOrigin()):Length() < ParanoidAgent.DeadRingerProximity then --and (cmd.buttons & IN_ATTACK2) == 0 then
			cmd:SetButtons( cmd.buttons | IN_ATTACK2)
			return
		end
	end
end



--257 = ready to stab
function ParanoidAgent.AimDanger(enemies, cmd)
	if #enemies > 0 then
		local me = entities:GetLocalPlayer()
		if me:GetPropInt("m_iClass") ~= 8 or me:InCond(4) or me:GetPropInt("m_Shared", "m_bFeignDeathReady") == 1 then return end
		for _, enemy in pairs(enemies) do
			--if enemy ~= nil and me ~= nil and (enemy.Enemy:GetAbsOrigin() - me:GetAbsOrigin()):Length() < 200 then --melee swing range + buffer?
				local wpn = me:GetPropEntity("m_hActiveWeapon")
				if wpn:GetPropFloat("LocalActiveWeaponData", "m_flNextPrimaryAttack") < globals.TickCount() * globals.TickInterval() and (enemy.Enemy:GetAbsOrigin() - me:GetAbsOrigin()):Length() > 60 then
					if cmd.buttons & IN_ATTACK2 == 0 then
						cmd:SetButtons(cmd.buttons | IN_ATTACK2)
						return
					end
				end

			--end
		end
	end
end


table.insert(DangerLib.AreaDanger, ParanoidAgent.ProximityDanger)
table.insert(DangerLib.ProjectileDanger, ParanoidAgent.ProximityDanger)
table.insert(DangerLib.AimDanger, ParanoidAgent.AimDanger)
print("libparanoid loaded")


callbacks.Register("Unload", function() 
	for k, func in pairs(DangerLib.AreaDanger) do
		if func == ParanoidAgent.ProximityDanger then
			table.remove(DangerLib.AreaDanger, k)
		end
	end


	for k, func in pairs(DangerLib.ProjectileDanger) do
		if func == ParanoidAgent.ProximityDanger then
			table.remove(DangerLib.ProjectileDanger, k)
		end
	end



	for k, func in pairs(DangerLib.AimDanger) do
		if func == ParanoidAgent.AimDanger then
			table.remove(DangerLib.AimDanger, k)
		end
	end
end)
