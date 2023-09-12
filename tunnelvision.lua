tunnelvision = {
	Targeting = {}
}


if not DangerLib then
	local err, loaded = pcall(require, "DangerLib")
	assert(err, "Dangerlib not found!")
end



local font_calibri = draw.CreateFont( 'Tahoma', 25, 700, FONTFLAG_OUTLINE | FONTFLAG_DROPSHADOW )
function tunnelvision.Render()
	if #tunnelvision.Targeting > 0 then
		draw.SetFont( font_calibri )
		w, h = draw.GetScreenSize()
		height = h / 2
		draw.Color(255, 255, 255, 255)
		for _, v in pairs(tunnelvision.Targeting) do
			if v.FOV < 1.7 then
				draw.Color(255, 0, 0, 255)
				draw.Text( (w/2) - 100, (h / 2)-100, string.format("<-------- BIG RANGER ----------->", #tunnelvision.Targeting ))
			end

		end
		draw.Text( (w/2) - 100, (h / 2)-200, string.format("Enemies targetting me: %d", #tunnelvision.Targeting ))


		local localCoords= client.WorldToScreen(entities:GetLocalPlayer():GetAbsOrigin())
		for _, enemy in pairs(tunnelvision.Targeting) do
			local remoteCoords = client.WorldToScreen(enemy.Enemy:GetAbsOrigin() + enemy.Enemy:GetPropVector("localdata", "m_vecViewOffset[0]"))
			if not remoteCoords then return end
			draw.Line(w/2, h/2, remoteCoords[1], remoteCoords[2])
			draw.Text(math.round(0.2 * remoteCoords[1] + 0.8 * (w/2)), math.round(0.2 * remoteCoords[2] + 0.8 * (h/2)), string.format("%.3f", enemy.FOV)) 
		end
	end


	if #tunnelvision.bombs > 0 then
		local me = entities.GetLocalPlayer()
		for _, bomb in pairs(tunnelvision.bombs) do
			if (bomb:GetAbsOrigin() - me:GetAbsOrigin()):Length() < 200 then
				draw.SetFont( font_calibri )
				w, h = draw.GetScreenSize()
				height = h / 2
				draw.Color(255, 255, 255, 255)
				draw.Text( (w/2) - 100, (h / 2)-300, string.format("STICKIES NEARBY, CARE!"))
			end
		end
	end


end


function tunnelvision.bombs(bombs, cmde)
	tunnelvision.bombs = bombs
end


function tunnelvision.catch(enemies, cmd)
	tunnelvision.Targeting = enemies	
end

table.insert(DangerLib.AimDanger, tunnelvision.catch)
table.insert(DangerLib.AreaDanger, tunnelvision.bombs)

callbacks.Register("Draw", tunnelvision.Render) 
callbacks.Register("Unload", function() 
	for k, func in pairs(DangerLib.AimDanger) do
		if func == tunnelvision.catch then
			table.remove(DangerLib.AimDanger, k)
		end
	end


	for k, func in pairs(DangerLib.AreaDanger) do
		if func == tunnelvision.catch then
			table.remove(DangerLib.AimDanger, k)
		end
	end

end)
