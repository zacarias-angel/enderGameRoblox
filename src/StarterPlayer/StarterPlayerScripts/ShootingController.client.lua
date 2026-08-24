-- Tipo: LocalScript
-- Ubicación: StarterPlayer/StarterPlayerScripts/ShootingController
-- Contexto: Cliente

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local weaponCfg = Config.Weapon

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local PARTICIPANT_ATTRIBUTE = "BattleParticipant"

local fireWeapon = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("FireWeapon")
local weaponFired = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("WeaponFired")
local stateChanged = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("StateChanged")

local lastFireLocal = 0
local eliminated = false

local function getWeaponCfg()
	local id = player:GetAttribute("WeaponId")
	for _, w in ipairs(Config.Weapons) do
		if w.id == id then return w end
	end
	return Config.Weapons[1]
end

local function getLaserColor(weapon)
	local override = player:GetAttribute("LaserColor")
	if override ~= nil then return override end
	return weapon.color
end

local function getAimRay()
	local viewport = camera.ViewportSize
	local screenX = viewport.X / 2 + weaponCfg.CROSSHAIR_OFFSET_X
	local screenY = viewport.Y / 2 + weaponCfg.CROSSHAIR_OFFSET_Y
	local ray = camera:ViewportPointToRay(screenX, screenY)
	return ray.Origin, ray.Direction.Unit
end

local function getMuzzle(character)
	local blaster = character:FindFirstChild("ZB_Blaster")
	if not blaster then return nil end
	local barrel = blaster:FindFirstChild("Barrel")
	return barrel and barrel:FindFirstChild("Muzzle") or nil
end

local function drawLaser(fromPos, toPos, color, width)
	local distance = (toPos - fromPos).Magnitude
	if distance < 0.05 then return end

	local beam = Instance.new("Part")
	beam.Anchored = true
	beam.CanCollide = false
	beam.CanQuery = false
	beam.CastShadow = false
	beam.Material = Enum.Material.Neon
	beam.Color = color
	beam.Size = Vector3.new(width, width, distance)
	beam.CFrame = CFrame.lookAt(fromPos, toPos) * CFrame.new(0, 0, -distance / 2)
	beam.Parent = workspace

	local tween = TweenService:Create(
		beam,
		TweenInfo.new(weaponCfg.LASER_LIFETIME, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{ Transparency = 1, Size = Vector3.new(0.05, 0.05, distance) }
	)
	tween:Play()
	Debris:AddItem(beam, weaponCfg.LASER_LIFETIME + 0.05)
end

local function muzzleFlash(position, color)
	local flash = Instance.new("Part")
	flash.Anchored = true
	flash.CanCollide = false
	flash.CanQuery = false
	flash.CastShadow = false
	flash.Shape = Enum.PartType.Ball
	flash.Material = Enum.Material.Neon
	flash.Color = color
	flash.Size = Vector3.new(0.9, 0.9, 0.9)
	flash.CFrame = CFrame.new(position)
	flash.Parent = workspace

	local light = Instance.new("PointLight")
	light.Color = color
	light.Brightness = 6
	light.Range = 10
	light.Parent = flash

	Debris:AddItem(flash, weaponCfg.MUZZLE_FLASH_TIME)
end

local function impactSpark(position)
	local spark = Instance.new("Part")
	spark.Anchored = true
	spark.CanCollide = false
	spark.CanQuery = false
	spark.CastShadow = false
	spark.Shape = Enum.PartType.Ball
	spark.Material = Enum.Material.Neon
	spark.Color = Config.LedColors.ICE_TINT
	spark.Size = Vector3.new(0.5, 0.5, 0.5)
	spark.CFrame = CFrame.new(position)
	spark.Parent = workspace

	local tween = TweenService:Create(
		spark,
		TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ Transparency = 1, Size = Vector3.new(1.6, 1.6, 1.6) }
	)
	tween:Play()
	Debris:AddItem(spark, 0.25)
end

local function fire()
	local character = player.Character
	if not character then return end
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return end
	if eliminated then return end
	if player:GetAttribute(PARTICIPANT_ATTRIBUTE) ~= true then return end

	local weapon = getWeaponCfg()
	local stamina = player:GetAttribute("Stamina")
	if stamina == nil then stamina = 0 end
	if stamina < weapon.shotCost then
		return
	end

	local now = os.clock()
	if (now - lastFireLocal) < weapon.fireCooldown then
		return
	end
	lastFireLocal = now

	local aimOrigin, direction = getAimRay()

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { character }
	local ray = workspace:Raycast(aimOrigin, direction * weaponCfg.MAX_RANGE, params)
	local hitPos = ray and ray.Position or (aimOrigin + direction * weaponCfg.MAX_RANGE)

	local muzzle = getMuzzle(character)
	local muzzlePos = muzzle and muzzle.WorldPosition or rootPart.Position

	local laserColor = getLaserColor(weapon)
	muzzleFlash(muzzlePos, laserColor)
	drawLaser(muzzlePos, hitPos, laserColor, weapon.laserWidth)
	if ray then
		impactSpark(hitPos)
	end

	local serverDir = (hitPos - rootPart.Position)
	if serverDir.Magnitude > 0.001 then
		serverDir = serverDir.Unit
	else
		serverDir = direction
	end
	fireWeapon:FireServer(rootPart.Position, serverDir)

	local thrust = rootPart:FindFirstChild("ZB_ThrustForce")
	if thrust and thrust:IsA("VectorForce") then
		local recoil = -direction * weaponCfg.RECOIL_FORCE
		thrust.Force = thrust.Force + recoil
	end
end

stateChanged.OnClientEvent:Connect(function(state)
	if type(state) ~= "table" then return end
	eliminated = state.eliminated == true
end)

weaponFired.OnClientEvent:Connect(function(payload)
	if type(payload) ~= "table" then return end
	if payload.shooterUserId == player.UserId then return end
	if typeof(payload.fromPos) ~= "Vector3" or typeof(payload.toPos) ~= "Vector3" then return end
	if typeof(payload.color) ~= "Color3" or type(payload.width) ~= "number" then return end
	muzzleFlash(payload.fromPos, payload.color)
	drawLaser(payload.fromPos, payload.toPos, payload.color, payload.width)
	if payload.hit then
		impactSpark(payload.toPos)
	end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		fire()
	end
end)
