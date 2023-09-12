DangerLib = {
	Players = {},
	Targeting = {},
	Me = nil,
	MyAbsPos = nil,
	IgnoreCloaked = false,
	ProjectileClasses = {
		"CTFProjectile_Rocket",
		"CTFProjectile_Flare",
		"CTFProjectile_Arrow",
		"CTFProjectile_SentryRocket"
	},
	PipeBombClasses = {
		"CTFGrenadePipebombProjectile"
	},

	Projectiles = {},
	Stickies = {},
	Pipes = {},
	Cannon = {},

	--
	AimDanger = {},
	AreaDanger = {},
	ProjectileDanger = {},
}



function DangerLib.Detect(cmd)
	DangerLib.Me = entities:GetLocalPlayer()

	if not DangerLib.Me:IsAlive() then return end
	DangerLib.MyAbsPos = DangerLib.Me:GetAbsOrigin()
	

	if DangerLib.Me then
		if #DangerLib.AimDanger > 0 or #DangerLib.AreaDanger > 0 or #DangerLib.ProjectileDanger > 0 then
			DangerLib.GetEnemies()
		else
			return
		end

		if #DangerLib.AimDanger > 0 then
			DangerLib.GetPlayers()

			if #DangerLib.Targeting >= 0 then
				for _, func in pairs(DangerLib.AimDanger) do
					local err, ret = pcall(func, DangerLib.Targeting, cmd)
					if err ~= true then
						print("err: "..tostring(ret))
					end
				end
			end
		end


		if #DangerLib.AreaDanger > 0 or #DangerLib.ProjectileDanger > 0 then
			DangerLib.GetAllPipeBombs()
			DangerLib.GetPipes()
			DangerLib.GetCannon()
			if #DangerLib.Pipes >= 0 or #DangerLib.Cannon >= 0 then
				for _, func in pairs(DangerLib.AreaDanger) do
					if #DangerLib.Pipes > 0 then pcall(func, DangerLib.Pipes, cmd) end
					if #DangerLib.Cannon > 0 then pcall(func, DangerLib.Cannon, cmd) end
				end
			end


		end

		if #DangerLib.AreaDanger > 0 then 
			DangerLib.GetStickies()
			if #DangerLib.Stickies >= 0 then
				for _, func in pairs(DangerLib.AreaDanger) do
					pcall(func, DangerLib.Stickies, cmd)
				end
			end

		end


		if #DangerLib.ProjectileDanger > 0 then
			DangerLib.GetAllProjectiles()

			if #DangerLib.Projectiles >= 0 then
				for _, func in pairs(DangerLib.ProjectileDanger) do
					pcall(func, DangerLib.Projectiles, cmd)
				end
			end
		end
	end
end


function DangerLib.FOV()
end

function DangerLib.Projectiles()
	
end


function DangerLib.GetCannon()
	DangerLib.Cannon = {}
	for _, bomb in pairs(DangerLib.PipeBombs) do
		if bomb:GetPropInt("m_iType") == 3 then
			table.insert(DangerLib.Cannon, bomb)
		end
	end
end




function DangerLib.GetPipes()
	DangerLib.Pipes = {}
	for _, bomb in pairs(DangerLib.PipeBombs) do
		if bomb:GetPropInt("m_iType") == 0 then
			table.insert(DangerLib.Pipes, bomb)
		end
	end
end


function DangerLib.GetStickies()
	DangerLib.Stickies = {}
	for _, bomb in pairs(DangerLib.PipeBombs) do
		if bomb:GetPropInt("m_iType") == 1 then
			table.insert(DangerLib.Stickies, bomb)
		end
	end
end


function DangerLib.GetAllProjectiles()
	DangerLib.Projectiles = {}
	for _, bombs in pairs(DangerLib.ProjectileClasses) do
		for _, bomb in pairs(entities.FindByClass(bombs)) do
			if not bomb:IsDormant() then
				local owner = bomb:GetPropEntity("m_hLauncher")
				if owner ~= nil then
					if DangerLib.EnemyOwnsExplosive(owner) and DangerLib.Visible(bomb) then
						table.insert(DangerLib.Projectiles, bomb)
					end
				end
			end
		end
	end
end

function DangerLib.EnemyOwnsExplosive(explosive)
	for _, enemy in pairs(DangerLib.Enemies) do
		if explose then
			local owner = explose:GetPropEntity("m_hOwnerEntity")
			if owner and enemy and owner:GetIndex() == enemy:GetIndex() then
				return true
			end
		end
	end
	return false
end

function DangerLib.GetAllPipeBombs()
	DangerLib.PipeBombs = {}
	for _, bombs in pairs(DangerLib.PipeBombClasses) do
		for _, bomb in pairs(entities.FindByClass(bombs)) do
			if not bomb:IsDormant() then
				local owner = bomb:GetPropEntity("m_hLauncher")
				if owner ~= nil then
					if DangerLib.EnemyOwnsExplosive(owner) and DangerLib.Visible(bomb) then
						table.insert(DangerLib.PipeBombs, bomb)
					end
				end
			end
		end
	end
end

function DangerLib.GetEnemies()
	local list = {}
	for _, v in pairs(entities.FindByClass("CTFPlayer")) do
		if v and v ~= DangerLib.Me and  not v:IsDormant() then
			if v:GetTeamNumber() ~= DangerLib.Me:GetTeamNumber() then 
				table.insert(list, v)
			end
		end
	end
	DangerLib.Enemies = list
end

function DangerLib.GetPlayers()
	local list = {}
	for _, v in pairs(DangerLib.Enemies) do
		if DangerLib.IgnoreCloaked == false or not v:InCond(4) then --cloaked
			--print("visible? "..tostring(DangerLib.Visible(v)) .. " -> "..tostring(DangerLib.Aiming(v)))
			--print(string.format("fov: %s distance: %s", tostring(DangerLib.GetFov(v)), tostring((DangerLib.MyAbsPos - v:GetAbsOrigin()):Length())))
			local aiming, fov = DangerLib.Aiming(v)
			if aiming and DangerLib.Visible(v) then
				table.insert(list, {Enemy = v, FOV = fov })
			end
		end
	end
	DangerLib.Targeting = list
end

CONTENTS_SOLID = 0x1
CONTENTS_WINDOW = 0x2
CONTENTS_MONSTER = 0x2000000
CONTENTS_MOVEABLE = 0x4000
CONTENTS_DEBRIS = 0x4000000
CONTENTS_HITBOX = 0x40000000

CONTENTS_GRATE = 0x8
MASK_SHOT = (CONTENTS_SOLID|CONTENTS_MOVEABLE|CONTENTS_MONSTER|CONTENTS_WINDOW|CONTENTS_DEBRIS|CONTENTS_HITBOX)

function DangerLib.Visible(entity)
	if not entity or entity == nil then return false end
	local trace = function(source, target, targetIndex)
		local line = engine.TraceLine(source, target, MASK_SHOT | CONTENTS_GRATE)
		--print(tostring(line.entity:GetIndex()) .. " --> " .. tostring(targetIndex) .." -> " ..tostring(line.entity == targetIndex) .." -> ".. tostring(line.entity == DangerLib.Me:GetIndex()) .. " .-> " ..tostring(line.fraction).. " -> " ..tostring(DangerLib.Me:GetPropInt("m_Shared", "m_bFeignDeathReady")))

		return line.entity:GetIndex() == targetIndex or line.entity:GetIndex() == DangerLib.Me:GetIndex() or line.fraction >= 0.94
	end


	local entId = entity:GetIndex()
	local entEyes = nil
	if entity:IsPlayer() then 
		entEyes = entity:GetAbsOrigin() + entity:GetPropVector("localdata", "m_vecViewOffset[0]")
	else
		entEyes = entity:GetAbsOrigin()
	end

	for _, hitboxes in pairs(DangerLib.Me:GetHitboxes()) do
		for _, hitbox in pairs(hitboxes) do
			if trace(hitbox, entEyes, entId) then return true end
		end
	end

	return false
end

function DangerLib.LinearDanger(fov, distance)
	local points = {
		{x = 50,   y = 40},
		{x = 100,   y = 30},
		{x = 500,   y = 7 },
		{x = 1000,  y = 3.7 },
		{x = 1500,  y = 2.8 },
		{x = 2000,  y = 1.65 },
	}


--	table.sort(points, function(a, b) return a.x < b.x end)

	local m, c
	for i = 1, #points - 1 do
		if distance >= points[i].x and distance <= points[i+1].x then
			m = (points[i+1].y - points[i].y) / (points[i+1].x - points[i].x)
			c = points[i].y - (m * points[i].x)
			break
		end
	end

	if not m or not c then
		return fov <= 1.65 
	end

	local expected_fov = m * distance + c
	return fov <= expected_fov
end

function DangerLib.Aiming(entity)
	if entity then
		local absOrigin = entity:GetAbsOrigin()
		local fov = DangerLib.GetFov(entity)
		return DangerLib.LinearDanger(fov, (absOrigin - DangerLib.MyAbsPos):Length()), fov
	end

	return false, nil
end

function DangerLib.GetFov(entity)
	if entity then
		-- center of mass
		local PlaneAngles = DangerLib.PlaneAngles(entity:GetAbsOrigin() + (entity:GetPropVector("localdata", "m_vecViewOffset[0]") / 2), DangerLib.MyAbsPos)

		rAngl = DangerLib.SphereToCartesian(PlaneAngles)
		lAngl = DangerLib.SphereToCartesian(entity:GetPropVector("tfnonlocaldata", "m_angEyeAngles[0]"))

		local cosTheta = rAngl:Dot(lAngl) / ( rAngl:Length() * lAngl:Length() )
		cosTheta = math.max(-1, math.min(1, cosTheta))
		return math.deg(math.acos(cosTheta))
		
	end
	return 9999
end


function DangerLib.SphereToCartesian(vec)
	local p, y = math.rad(vec.x), math.rad(vec.y)
	return Vector3(
		math.cos(p) * math.cos(y),
		math.cos(p) * math.sin(y),
		math.sin(p)
	)
end

local DEGPRAD = 180 / math.pi
function DangerLib.PlaneAngles(from, dest)
	local delta = from - dest

	local p = math.atan(delta.z, math.sqrt(delta.x ^2 + delta.y ^2)) * DEGPRAD
	local y = math.atan(delta.y, delta.x) * ( 180 /  math.pi) + 180

	return Vector3(p, y, 0)
end


callbacks.Register("CreateMove", DangerLib.Detect)

print("Dangerlib loaded x4")
return DangerLib
