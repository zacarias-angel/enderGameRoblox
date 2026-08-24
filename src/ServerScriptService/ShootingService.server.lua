-- Tipo: Script
-- Ubicación: ServerScriptService/ShootingService
-- Contexto: Servidor

--[[
	ShootingService
	Recibe las peticiones de disparo del cliente (FireWeapon), las valida con
	autoridad total del servidor (cadencia, rango, personaje objetivo vivo) y
	re-realiza el raycast en el servidor para evitar exploits. Si el impacto es
	válido, delega el efecto a FreezeService.
	EL CLIENTE NUNCA TIENE AUTORIDAD (ReglasRoblox.md §4).
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local FreezeMap = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("FreezeMap"))

local function ensureRemote(name)
	local folder = ReplicatedStorage:FindFirstChild("RemoteEvents")
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "RemoteEvents"
		folder.Parent = ReplicatedStorage
	end
	local remote = folder:FindFirstChild(name)
	if not remote then
		remote = Instance.new("RemoteEvent")
		remote.Name = name
		remote.Parent = folder
	end
	return remote
end

local fireWeapon = ensureRemote("FireWeapon")
local weaponFired = ensureRemote("WeaponFired")
local fireVfx = ensureRemote("FireWeaponVfx")
local hookVfx = ensureRemote("HookVfx")

local lastFire = {}

local function getServices()
	local zb = _G.ZB
	if zb then
		return zb.PlayerState, zb.FreezeService, zb.RankService
	end
	return nil, nil, nil
end

local function characterFromPart(part)
	if not part then return nil end
	local model = part:FindFirstAncestorOfClass("Model")
	while model do
		if model:FindFirstChildOfClass("Humanoid") then
			return model
		end
		model = model:FindFirstAncestorOfClass("Model")
	end
	return nil
end

local function validateAndResolve(shooter, origin, direction)
	local shooterChar = shooter.Character
	if not shooterChar then return nil, Config.HitResult.NONE end

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { shooterChar }

	local ray = workspace:Raycast(origin, direction * Config.Weapon.MAX_RANGE, params)
	if not ray or not ray.Instance then
		return nil, Config.HitResult.NONE, origin + direction * Config.Weapon.MAX_RANGE
	end

	local targetChar = characterFromPart(ray.Instance)
	if not targetChar then
		return nil, Config.HitResult.NONE, ray.Position
	end

	local hitResult = FreezeMap.resolve(ray.Instance.Name)
	return targetChar, hitResult, ray.Position
end

local function getLaserColor(player, weapon)
	local override = player:GetAttribute("LaserColor")
	if typeof(override) == "Color3" then
		return override
	end
	return weapon.color
end

local function getMuzzlePosition(character)
	local blaster = character and character:FindFirstChild("ZB_Blaster")
	local barrel = blaster and blaster:FindFirstChild("Barrel")
	local muzzle = barrel and barrel:FindFirstChild("Muzzle")
	if muzzle and muzzle:IsA("Attachment") then
		return muzzle.WorldPosition
	end
	local root = character and character:FindFirstChild("HumanoidRootPart")
	return root and root.Position or nil
end

local function getWeapon(player)
	local id = player:GetAttribute("WeaponId")
	for _, weapon in ipairs(Config.Weapons) do
		if weapon.id == id then return weapon end
	end
	return Config.Weapons[1]
end

local function getLaserColor(player, weapon)
	local override = player:GetAttribute("LaserColor")
	if override ~= nil then return override end
	return weapon.color
end

local function onFire(shooter, origin, direction)
	local PlayerState, FreezeService, RankService = getServices()
	if not PlayerState or not FreezeService then return end

	if typeof(origin) ~= "Vector3" or typeof(direction) ~= "Vector3" then
		return
	end
	if direction.Magnitude < 0.001 then return end
	direction = direction.Unit

	if not PlayerState.isAlive(shooter) then return end
	if shooter:GetAttribute("BattleParticipant") ~= true then return end

	if _G.ZB and _G.ZB.GameMode and not _G.ZB.GameMode.isZeroG() then
		return
	end

	local weapon = getWeapon(shooter)

	local now = os.clock()
	if lastFire[shooter] and (now - lastFire[shooter]) < weapon.fireCooldown then
		return
	end
	lastFire[shooter] = now

	local shooterRoot = shooter.Character and shooter.Character:FindFirstChild("HumanoidRootPart")
	if not shooterRoot then return end
	local maxOriginDist = 8
	if (origin - shooterRoot.Position).Magnitude > maxOriginDist then
		return
	end

	local Stamina = _G.ZB and _G.ZB.Stamina
	if Stamina and not Stamina.spend(shooter, weapon.shotCost) then
		return
	end

	local vfxParams = RaycastParams.new()
	vfxParams.FilterType = Enum.RaycastFilterType.Exclude
	vfxParams.FilterDescendantsInstances = { shooter.Character }
	local vfxRay = workspace:Raycast(origin, direction * Config.Weapon.MAX_RANGE, vfxParams)
	local hitPos = vfxRay and vfxRay.Position or (origin + direction * Config.Weapon.MAX_RANGE)

	fireVfx:FireAllClients({
		shooter = shooter,
		from = origin,
		to = hitPos,
		color = getLaserColor(shooter, weapon),
		width = weapon.laserWidth,
		hit = vfxRay ~= nil,
	})

	local targetChar, hitResult, hitPos = validateAndResolve(shooter, origin, direction)
	local muzzlePos = getMuzzlePosition(shooter.Character)
	if muzzlePos and hitPos then
		weaponFired:FireAllClients({
			shooterUserId = shooter.UserId,
			fromPos = muzzlePos,
			toPos = hitPos,
			color = getLaserColor(shooter, weapon),
			width = weapon.laserWidth,
			hit = hitResult ~= Config.HitResult.NONE,
		})
	end
	if not targetChar or hitResult == Config.HitResult.NONE then
		return
	end

	if targetChar == shooter.Character then return end

	local applied = FreezeService.apply(targetChar, hitResult)

	if applied and RankService then
		if hitResult == Config.HitResult.ELIMINATE then
			RankService.addScore(shooter, "elimination")
		else
			RankService.addScore(shooter, "limbFreeze")
		end
	end
end

fireWeapon.OnServerEvent:Connect(onFire)

hookVfx.OnServerEvent:Connect(function(player, event, anchorPos, anchorPlayer)
	if not player or not player.Parent then return end
	if typeof(event) ~= "string" then return end
	hookVfx:FireAllClients({
		player = player,
		event = event,
		anchorPos = (typeof(anchorPos) == "Vector3") and anchorPos or nil,
		anchorPlayer = anchorPlayer,
	})
end)

Players.PlayerRemoving:Connect(function(player)
	lastFire[player] = nil
end)
