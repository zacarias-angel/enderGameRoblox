-- Tipo: LocalScript
-- Ubicación: StarterPlayer/StarterPlayerScripts/ShootingController
-- Contexto: Cliente

--[[
	ShootingController
	Detecta el disparo (click izquierdo), hace un raycast local desde la cámara
	para el VFX del láser y envía origin+direction al servidor por FireWeapon.
	El láser parte del Muzzle del blaster (WeaponSetup) hacia el punto apuntado,
	con beam neón + fade, muzzle flash y chispa de impacto.
	NO calcula daño ni congelación: eso lo decide y valida el servidor.
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local weaponCfg = Config.Weapon

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local fireWeapon = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("FireWeapon")

local lastFireLocal = 0

local function getMuzzle(character)
	-- Propósito: Obtener el Attachment "Muzzle" del blaster si existe.
	-- Precondiciones:
	--   1. character es el personaje local.
	-- Ubicación: StarterPlayerScripts/ShootingController
	-- Retorna: Attachment o nil
	local blaster = character:FindFirstChild("ZB_Blaster")
	if not blaster then return nil end
	local barrel = blaster:FindFirstChild("Barrel")
	return barrel and barrel:FindFirstChild("Muzzle") or nil
end

local function drawLaser(fromPos, toPos)
	-- Propósito: VFX del láser: beam neón con fade entre origen e impacto.
	-- Precondiciones:
	--   1. fromPos y toPos son Vector3.
	-- Ubicación: StarterPlayerScripts/ShootingController
	-- Retorna: nil
	local distance = (toPos - fromPos).Magnitude
	if distance < 0.05 then return end

	local beam = Instance.new("Part")
	beam.Anchored = true
	beam.CanCollide = false
	beam.CanQuery = false
	beam.CastShadow = false
	beam.Material = Enum.Material.Neon
	beam.Color = weaponCfg.LASER_COLOR
	beam.Size = Vector3.new(weaponCfg.LASER_WIDTH, weaponCfg.LASER_WIDTH, distance)
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

local function muzzleFlash(position)
	-- Propósito: Destello breve en la boca del cañón.
	-- Precondiciones:
	--   1. position es Vector3.
	-- Ubicación: StarterPlayerScripts/ShootingController
	-- Retorna: nil
	local flash = Instance.new("Part")
	flash.Anchored = true
	flash.CanCollide = false
	flash.CanQuery = false
	flash.CastShadow = false
	flash.Shape = Enum.PartType.Ball
	flash.Material = Enum.Material.Neon
	flash.Color = weaponCfg.LASER_COLOR
	flash.Size = Vector3.new(0.9, 0.9, 0.9)
	flash.CFrame = CFrame.new(position)
	flash.Parent = workspace

	local light = Instance.new("PointLight")
	light.Color = weaponCfg.LASER_COLOR
	light.Brightness = 6
	light.Range = 10
	light.Parent = flash

	Debris:AddItem(flash, weaponCfg.MUZZLE_FLASH_TIME)
end

local function impactSpark(position)
	-- Propósito: Chispa/destello en el punto de impacto.
	-- Precondiciones:
	--   1. position es Vector3.
	-- Ubicación: StarterPlayerScripts/ShootingController
	-- Retorna: nil
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
	-- Propósito: Ejecutar un disparo local (VFX) + petición al servidor.
	-- Precondiciones:
	--   1. Personaje local existente.
	-- Ubicación: StarterPlayerScripts/ShootingController
	-- Retorna: nil
	local character = player.Character
	if not character then return end
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return end

	-- Cadencia local (feedback inmediato; el servidor revalida).
	local now = os.clock()
	if (now - lastFireLocal) < weaponCfg.FIRE_COOLDOWN then
		return
	end
	lastFireLocal = now

	-- Dirección desde la cámara; origen para gameplay = root (validado en server).
	local aimOrigin = camera.CFrame.Position
	local direction = camera.CFrame.LookVector

	-- Raycast desde la cámara para saber a qué se apunta.
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { character }
	local ray = workspace:Raycast(aimOrigin, direction * weaponCfg.MAX_RANGE, params)
	local hitPos = ray and ray.Position or (aimOrigin + direction * weaponCfg.MAX_RANGE)

	-- Origen visual del láser: el muzzle del blaster si existe, si no el root.
	local muzzle = getMuzzle(character)
	local muzzlePos = muzzle and muzzle.WorldPosition or rootPart.Position

	muzzleFlash(muzzlePos)
	drawLaser(muzzlePos, hitPos)
	if ray then
		impactSpark(hitPos)
	end

	-- El servidor recibe origen del root y la dirección al objetivo real.
	local serverDir = (hitPos - rootPart.Position)
	if serverDir.Magnitude > 0.001 then
		serverDir = serverDir.Unit
	else
		serverDir = direction
	end
	fireWeapon:FireServer(rootPart.Position, serverDir)
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		fire()
	end
end)
