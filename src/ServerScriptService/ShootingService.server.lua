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
	-- Propósito: Obtener/crear un RemoteEvent en ReplicatedStorage/RemoteEvents.
	-- Precondiciones:
	--   1. name es un string no vacío.
	-- Ubicación: ServerScriptService/ShootingService
	-- Retorna: RemoteEvent
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

-- Control de cadencia por jugador.
local lastFire = {}

local function getServices()
	-- Propósito: Obtener PlayerState y FreezeService (esperando si aún no cargan).
	-- Precondiciones: ninguna.
	-- Ubicación: ServerScriptService/ShootingService
	-- Retorna: (PlayerState, FreezeService) o (nil, nil)
	local zb = _G.ZB
	if zb then
		return zb.PlayerState, zb.FreezeService
	end
	return nil, nil
end

local function characterFromPart(part)
	-- Propósito: Encontrar el personaje (con Humanoid) dueño de una parte.
	--            Funciona con jugadores y con dummies (Humanoid sin Player).
	-- Precondiciones:
	--   1. part es una BasePart o nil.
	-- Ubicación: ServerScriptService/ShootingService
	-- Retorna: Model del personaje o nil.
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
	-- Propósito: Re-raycast en servidor y resolver la parte impactada.
	-- Precondiciones:
	--   1. shooter es un Player válido y vivo.
	--   2. origin es Vector3; direction es Vector3 unitario aproximado.
	-- Ubicación: ServerScriptService/ShootingService
	-- Retorna: (Model objetivo, string hitResult) o (nil, NONE)
	local shooterChar = shooter.Character
	if not shooterChar then return nil, Config.HitResult.NONE end

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { shooterChar }

	local ray = workspace:Raycast(origin, direction * Config.Weapon.MAX_RANGE, params)
	if not ray or not ray.Instance then
		return nil, Config.HitResult.NONE
	end

	local targetChar = characterFromPart(ray.Instance)
	if not targetChar then
		return nil, Config.HitResult.NONE
	end

	local hitResult = FreezeMap.resolve(ray.Instance.Name)
	return targetChar, hitResult
end

local function onFire(shooter, origin, direction)
	-- Propósito: Manejar una petición de disparo validando todo en servidor.
	-- Precondiciones:
	--   1. shooter es el Player que disparó (inyectado por el RemoteEvent).
	--   2. origin/direction llegan del cliente y NO son de confianza.
	-- Ubicación: ServerScriptService/ShootingService
	-- Retorna: nil
	local PlayerState, FreezeService = getServices()
	if not PlayerState or not FreezeService then return end

	-- Validación de tipos (input no confiable).
	if typeof(origin) ~= "Vector3" or typeof(direction) ~= "Vector3" then
		return
	end
	if direction.Magnitude < 0.001 then return end
	direction = direction.Unit

	-- El tirador debe estar vivo.
	if not PlayerState.isAlive(shooter) then return end

	-- Cadencia.
	local now = os.clock()
	if lastFire[shooter] and (now - lastFire[shooter]) < Config.Weapon.FIRE_COOLDOWN then
		return
	end
	lastFire[shooter] = now

	-- Validar origen: no debe estar lejos del personaje (anti teleport-shot).
	local shooterRoot = shooter.Character and shooter.Character:FindFirstChild("HumanoidRootPart")
	if not shooterRoot then return end
	local maxOriginDist = 8
	if (origin - shooterRoot.Position).Magnitude > maxOriginDist then
		return
	end

	local targetChar, hitResult = validateAndResolve(shooter, origin, direction)
	if not targetChar or hitResult == Config.HitResult.NONE then
		return
	end

	-- No permitir autolesión.
	if targetChar == shooter.Character then return end

	FreezeService.apply(targetChar, hitResult)
end

fireWeapon.OnServerEvent:Connect(onFire)

Players.PlayerRemoving:Connect(function(player)
	lastFire[player] = nil
end)
