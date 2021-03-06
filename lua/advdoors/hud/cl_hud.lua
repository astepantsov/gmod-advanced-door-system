AdvDoors.KeyLocked = false
AdvDoors.DoorbellLocked = false
AdvDoors.OpenButton = AdvDoors.OpenButton or MOUSE_RIGHT
function CalcDoorDrawPosition(door)
	local center = door:OBBCenter()
	local dimensions = door:OBBMins() - door:OBBMaxs()
	dimensions.x = math.abs(dimensions.x)
	dimensions.y = math.abs(dimensions.y)
	dimensions.z = math.abs(dimensions.z)

	local world_center = door:LocalToWorld(center)

	local trace = {
		endpos = world_center, 
		filter = ents.FindInSphere(world_center, 50),
		ignoreworld = true
	}

	table.RemoveByValue(trace.filter, door)

	local TraceStart, TraceStartRev, Width
	local x, y
	if dimensions.z < dimensions.x and dimensions.z < dimensions.y then
		x = "y"
		y = "x"
		TraceStart = trace.endpos + door:GetUp() * dimensions.z
		TraceStartRev = trace.endpos - door:GetUp() * dimensions.z
		Width = dimensions.y
	elseif dimensions.x < dimensions.y then
		x = "y"
		y = "z"
		Width = dimensions.y
		TraceStart = trace.endpos + door:GetForward() * dimensions.x
		TraceStartRev = trace.endpos - door:GetForward() * dimensions.x
	elseif dimensions.y < dimensions.x then
		x = "x"
		y = "z"
		Width = dimensions.x
		TraceStart = trace.endpos + door:GetRight() * dimensions.y
		TraceStartRev = trace.endpos - door:GetRight() * dimensions.y
	end

	trace.start = TraceStart;
	local tr = util.TraceLine(trace);
	trace.start = TraceStartRev
	local tr_rev = util.TraceLine(trace);

	local ang, ang_rev = tr.HitNormal:Angle(), tr_rev.HitNormal:Angle();
	ang:RotateAroundAxis(ang:Forward(), 90);
	ang:RotateAroundAxis(ang:Right(), 270);
	ang_rev:RotateAroundAxis(ang_rev:Forward(), 90);
	ang_rev:RotateAroundAxis(ang_rev:Right(), 270);
	local pos, pos_rev = tr.HitPos, tr_rev.HitPos

	return pos, ang, pos_rev, ang_rev, Width, x, y
end

function GenerateDoorList()
	local DoorList = {}
	for _, door in pairs(ents.GetAll()) do
		if door:isDoor() and LocalPlayer():GetPos():Distance(door:GetPos()) < 300 then
			local pos, ang, pos_rev, ang_rev, width, xl, yl = CalcDoorDrawPosition(door);
			table.insert(DoorList, {Position = pos, Angle = ang, Width = width, Entity = door, XL = xl, YL = yl})
			table.insert(DoorList, {Position = pos_rev, Angle = ang_rev, Width = width, Entity = door,  XL = xl, YL = yl})
		end
	end
	return DoorList
end

CORNER_RIGHT = 1
CORNER_LEFT = -1
CORNER_UP = -1
CORNER_DOWN = 1

function draw.Corner(origin_x, origin_y, type_x, type_y, length, color)
	surface.SetDrawColor(color);
	surface.DrawLine(origin_x, origin_y, origin_x + length * type_x, origin_y);
	surface.DrawLine(origin_x, origin_y, origin_x, origin_y + length * type_y);
end

function draw.CornerBox(origin_x, origin_y, x, y, length, color)
	draw.Corner(origin_x, origin_y, CORNER_RIGHT, CORNER_DOWN, length, color)
	draw.Corner(origin_x + x, origin_y, CORNER_LEFT, CORNER_DOWN, length, color)
	draw.Corner(origin_x, origin_y + y, CORNER_RIGHT, CORNER_UP, length, color)
	draw.Corner(origin_x + x, origin_y + y, CORNER_LEFT, CORNER_UP, length, color)
end

local locked, unlocked, rent, bell

AdvDoors.DownloadMaterial("http://i.imgur.com/kyXExEL.png", function(self) locked = self end) -- Icon made by http://www.flaticon.com/authors/madebyoliver from www.flaticon.com
AdvDoors.DownloadMaterial("http://i.imgur.com/axjRFV1.png", function(self) unlocked = self end) -- Icon made by http://www.flaticon.com/authors/madebyoliver from www.flaticon.com
AdvDoors.DownloadMaterial("http://i.imgur.com/qr9JX3t.png", function(self) rent = self end) -- Icon made by http://www.flaticon.com/authors/roundicons from www.flaticon.com
AdvDoors.DownloadMaterial("http://i.imgur.com/4ZlW2gE.png", function(self) bell = self end) -- Icon made by http://www.flaticon.com/authors/madebyoliver from www.flaticon.com

local fadeColor = 0
local fadeDirection = true
local fadeStart = CurTime();

hook.Add("PostDrawTranslucentRenderables", "AdvancedDoorSystem_DrawDoorData", function()
	for _,v in pairs(GenerateDoorList()) do
		if v.Entity:isKeysOwnable() and not v.Entity:getKeysNonOwnable() and not v.Entity:isDoorBlacklisted() and not v.Entity:isDoorTypeBlacklisted() and not v.Entity:isDoorModelBlacklisted() then
			local trace = {
				start = LocalPlayer():GetShootPos(),
				endpos = LocalPlayer():GetAimVector() * 295 + LocalPlayer():GetShootPos(),
				filter = LocalPlayer()
			}
			local tr = util.TraceLine(trace)
			local pos = v.Entity:WorldToLocal(tr.HitPos)

			cam.Start3D2D(v.Position, v.Angle, 0.1)
			local w = math.min(47/0.1, v.Width/0.1)
			local h = 48/0.1
			surface.SetDrawColor(Color(0, 0, 0, 150))
			surface.DrawRect(-w/2, -h/2, w, h)
			draw.CornerBox(-w/2, -h/2, w, h, 10, Color(255, 255, 255, 150))
			draw.SimpleText(v.Entity:getKeysTitle() or AdvDoors.LANG.GetString("unnamed"), "AdvDoorsMain", 0, -h/2 + 10, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
			surface.SetDrawColor(Color(150, 150, 150, 50))
			surface.DrawLine(-w/2, -h/2 + 60, w/2, -h/2 + 60)
			surface.DrawOutlinedRect(-w/2, -h/2, w + 1, h + 1)
			if AdvDoors.isLocked(v.Entity) then
				surface.SetDrawColor(Color(227, 94, 5, 150))
				surface.DrawRect(-w/2, -h/2 + 60, 64, 64);
				surface.SetMaterial(locked)
				draw.SimpleText(AdvDoors.LANG.GetString("locked"), "AdvDoorsMain", 0, -h/2 + 92, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			else
				surface.SetDrawColor(Color(165, 255, 105, 150))
				surface.DrawRect(-w/2, -h/2 + 60, 64, 64);
				surface.SetMaterial(unlocked)
				draw.SimpleText(AdvDoors.LANG.GetString("not_locked"), "AdvDoorsMain", 0, -h/2 + 92, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
			draw.CornerBox(-w/2, -h/2 + 60, w, 64, 10, Color(255, 255, 255, 150));
			draw.Corner(-w/2, -h/2 + 60, CORNER_RIGHT, CORNER_UP, 10, Color(255, 255, 255, 150))
			draw.Corner(w/2, -h/2 + 60, CORNER_LEFT, CORNER_UP, 10, Color(255, 255, 255, 150))
			surface.SetDrawColor(255, 255, 255, 150)
			surface.DrawTexturedRect(-w/2 + 2, -h/2 + 62, 60, 60)
			surface.SetDrawColor(Color(150, 150, 150, 50))
			surface.DrawLine(-w/2, -h/2 + 124, w/2, -h/2 + 124)
			surface.DrawLine(-w/2 + 64, -h/2 + 60, -w/2 + 64, -h/2 + 124)
			draw.CornerBox(-w/2, -h/2 + 124, w, 60, 10, Color(255, 255, 255, 150));
			draw.SimpleText((AdvDoors.getOwnerName(v.Entity) or v.Entity:getKeysDoorGroup() or (v.Entity:getKeysDoorTeams() and AdvDoors.LANG.GetString("spec_jobs")) or AdvDoors.LANG.GetString("unowned")), "AdvDoorsMain", 0, -h/2 + 154, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			surface.SetDrawColor(Color(150, 150, 150, 50))
			surface.DrawLine(-w/2, -h/2 + 184, w/2, -h/2 + 184)
			surface.DrawLine(-w/2, -h/2 + 244, w/2, -h/2 + 244)
			if (AdvDoors.getOwner(v.Entity) and v.Entity:GetNWBool("canRent", false) and not v.Entity:GetNWEntity("tenant", false)) then
				local fadeFraction = math.Clamp((CurTime() - fadeStart) / 1.5, 0, 1);
				fadeColor = Lerp(fadeFraction, fadeDirection and 0 or 100, fadeDirection and 100 or 0); 
				if fadeColor >= 100 then fadeDirection = false; fadeStart = CurTime() elseif fadeColor <= 0 then fadeDirection = true; fadeStart = CurTime() end
				surface.SetDrawColor(Color(mgui.Colors.Red.r, mgui.Colors.Red.g, mgui.Colors.Red.b, fadeColor))
				surface.DrawRect(-w/2 + 2, -h/2 + 184, w-2, 60)
			end
			draw.SimpleText((AdvDoors.getOwner(v.Entity) and v.Entity:GetNWBool("canRent", false) and not v.Entity:GetNWEntity("tenant", false)) and AdvDoors.LANG.GetString("rent_available") or AdvDoors.LANG.GetString("rent_unavailable"), "AdvDoorsMain", 0, -h/2 + 214, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			surface.SetMaterial(rent)
			surface.SetDrawColor(255, 255, 255, 255)
			surface.DrawTexturedRect(-w/2 + 2, -h/2 + 184, 60, 60)
			draw.CornerBox(-w/2, -h/2 + 184, w, 60, 10, Color(255, 255, 255, 150));
			draw.CornerBox(-w/2, h/2 - 60, w, 60, 10, Color(255, 255, 255, 150));
			local PosLocal = v.Entity:WorldToLocal(v.Position)
			surface.SetDrawColor(Color(150, 150, 150, 50))
			surface.DrawLine(-w/2, h/2 - 60, w/2, h/2 - 60)
			surface.DrawLine(-w/2, h/2 - 120, w/2, h/2 - 120)
			if tr.Entity == v.Entity and pos[v.XL] > PosLocal[v.XL] - 47/2 and pos[v.XL] < PosLocal[v.XL] + 47/2 and pos[v.YL] < PosLocal[v.YL] - 48/2 + 120/10 and pos[v.YL] > PosLocal[v.YL] - 48/2 + 60/10 and LocalPlayer():GetPos():Distance(v.Entity:GetPos()) < 200 then
				surface.SetDrawColor(Color(69, 48, 23, 150))
				surface.DrawRect(-w/2, h/2 - 120, w, 60, 10)
				if input.IsMouseDown(AdvDoors.OpenButton) and not AdvDoors.KeyLocked then
					AdvDoors.KeyLocked = true
					AdvDoors.openMenu(v.Entity);
				end
			end
			
			if tr.Entity == v.Entity and pos[v.XL] > PosLocal[v.XL] - 47/2 and pos[v.XL] < PosLocal[v.XL] + 47/2 and pos[v.YL] < PosLocal[v.YL] - 48/2 + 236/10 and pos[v.YL] > PosLocal[v.YL] - 48/2 + 176/10 and LocalPlayer():GetPos():Distance(v.Entity:GetPos()) < 100 and AdvDoors.hasModification(v.Entity, 1) then
				surface.SetDrawColor(Color(69, 48, 23, 150))
				surface.DrawRect(-w/2, h/2 - 236, w, 60, 10)
				if input.IsMouseDown(AdvDoors.OpenButton) and not AdvDoors.DoorbellLocked then
					AdvDoors.DoorbellLocked = true
					AdvDoors.useBell(v.Entity);
					timer.Simple(5, function()
						AdvDoors.DoorbellLocked = false
					end)
				end
			end
			draw.CornerBox(-w/2, h/2 - 120, w, 60, 10, Color(255, 255, 255, 150));
			draw.SimpleText(AdvDoors.LANG.GetString("open_menu"), "AdvDoorsMain", 0, h/2 - 90, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			
			if AdvDoors.hasModification(v.Entity, 1) then
				draw.CornerBox(-w/2, h/2 - 236, w, 60, 10, Color(255, 255, 255, 150));
				surface.SetMaterial(bell)
				surface.SetDrawColor(255, 255, 255, 255)
				surface.DrawTexturedRect(-w/2 + 2, -h/2 + 244, 60, 60)
				draw.SimpleText(AdvDoors.LANG.GetString("use_bell"), "AdvDoorsMain", 0, h/2 - 205, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				surface.SetDrawColor(Color(150, 150, 150, 50))
				surface.DrawLine(-w/2, -h/2 + 304, w/2, -h/2 + 304)
			end
			
			cam.End3D2D()
		end
	end
end)