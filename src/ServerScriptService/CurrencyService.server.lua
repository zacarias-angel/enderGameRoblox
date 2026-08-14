-- Tipo: Script
-- Ubicación: ServerScriptService/CurrencyService
-- Contexto: Servidor

--[[
	CurrencyService
	Sistema de monedas del juego. Las monedas sirven para comprar/mejorar
	items (pendiente). Este servicio:
	- Crea el leaderstat "Monedas" en cada jugador.
	- Spawnea monedas en el lobby (piso) y en la arena (cúpula geodésica).
	  ~100 monedas cada 30 minutos.
	- Detecta cuando un jugador toca una moneda y la recolecta.

	Expone API: _G.ZB.CurrencyService.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local curCfg = Config.Currency

local activeCoins = {}

local function getCoinFolder()
	-- Propósito: Obtener/crear la carpeta de monedas en workspace.
	-- Precondiciones: ninguna.
	-- Ubicación: ServerScriptService/CurrencyService
	-- Retorna: Folder
	local folder = workspace:FindFirstChild("Coins")
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "Coins"
		folder.Parent = workspace
	end
	return folder
end

local function getLeaderstat(player)
	-- Propósito: Obtener/crear el leaderstat de monedas del jugador.
	-- Precondiciones:
	--   1. player es un Player válido.
	-- Ubicación: ServerScriptService/CurrencyService
	-- Retorna: IntValue
	local stats = player:FindFirstChild("leaderstats")
	if not stats then
		stats = Instance.new("Folder")
		stats.Name = "leaderstats"
		stats.Parent = player
	end
	local coins = stats:FindFirstChild(curCfg.LEADERSTAT)
	if not coins then
		coins = Instance.new("IntValue")
		coins.Name = curCfg.LEADERSTAT
		coins.Value = curCfg.STARTING_COINS
		coins.Parent = stats
	end
	return coins
end

local function randomLobbyPosition()
	-- Propósito: Posición aleatoria dentro del lobby (piso).
	-- Precondiciones: ninguna.
	-- Ubicación: ServerScriptService/CurrencyService
	-- Retorna: Vector3
	local piso = workspace:FindFirstChild("piso")
	if not piso then return nil end
	local pos = piso.Position
	local hw = piso.Size.X / 2
	local hd = piso.Size.Z / 2
	local top = pos.Y + piso.Size.Y / 2

	local x = pos.X + (math.random() * 2 - 1) * (hw - 8)
	local z = pos.Z + (math.random() * 2 - 1) * (hd - 8)
	return Vector3.new(x, top + curCfg.SPAWN_HEIGHT, z)
end

local function randomArenaPosition()
	-- Propósito: Posición aleatoria dentro de la cúpula geodésica (arena).
	-- Precondiciones: ninguna.
	-- Ubicación: ServerScriptService/CurrencyService
	-- Retorna: Vector3 o nil
	local geo = workspace:FindFirstChild("sm_Roblox_spaceshooter_geodesica_V2 (1)")
	if not geo then return nil end

	local estructura = geo:FindFirstChild("estructura")
	if not estructura or not estructura:IsA("BasePart") then return nil end

	local center = estructura.Position
	local half = estructura.Size / 2

	local x = center.X + (math.random() * 2 - 1) * (half.X - 20)
	local y = center.Y + (math.random() * 2 - 1) * (half.Y - 20)
	local z = center.Z + (math.random() * 2 - 1) * (half.Z - 20)
	return Vector3.new(x, y, z)
end

local function getRandomSpawnPosition()
	-- Propósito: Elegir una posición de spawn (lobby o arena).
	-- Precondiciones: ninguna.
	-- Ubicación: ServerScriptService/CurrencyService
	-- Retorna: Vector3
	-- 50% lobby, 50% arena
	if math.random() < 0.5 then
		local lobby = randomLobbyPosition()
		if lobby then return lobby end
	end
	local arena = randomArenaPosition()
	if arena then return arena end

	-- Fallback al lobby
	local lobby = randomLobbyPosition()
	if lobby then return lobby end
	return Vector3.new(0, 10, 0)
end

local function spawnCoin()
	-- Propósito: Crear una moneda en una posición aleatoria.
	-- Precondiciones: ninguna.
	-- Ubicación: ServerScriptService/CurrencyService
	-- Retorna: nil
	if #activeCoins >= curCfg.MAX_CONCURRENT_COINS then return end

	local coin = Instance.new("Part")
	coin.Name = curCfg.COIN_NAME
	coin.Anchored = true
	coin.CanCollide = true   -- IMPORTANTE: true para que Touched funcione
	coin.CanQuery = false
	coin.CastShadow = false
	coin.Shape = Enum.PartType.Ball
	coin.Size = curCfg.COIN_SIZE
	coin.Color = curCfg.COIN_COLOR
	coin.Material = Enum.Material.Neon
	coin.CFrame = CFrame.new(getRandomSpawnPosition())
	coin.Parent = getCoinFolder()

	local light = Instance.new("PointLight")
	light.Color = curCfg.COIN_COLOR
	light.Range = 8
	light.Brightness = 1.5
	light.Parent = coin

	local collected = false
	coin.Touched:Connect(function(hit)
		if collected then return end
		local character = hit.Parent
		if not character then return end
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if not humanoid then return end
		local player = Players:GetPlayerFromCharacter(character)
		if not player then return end

		collected = true
		local coins = getLeaderstat(player)
		coins.Value = coins.Value + curCfg.COIN_VALUE

		activeCoins[coin] = nil
		coin:Destroy()
	end)

	activeCoins[coin] = true
end

local CurrencyService = {}

function CurrencyService.getCoins(player)
	-- Propósito: Obtener las monedas actuales de un jugador.
	-- Precondiciones:
	--   1. player es un Player válido.
	-- Ubicación: ServerScriptService/CurrencyService
	-- Retorna: number
	return getLeaderstat(player).Value
end

function CurrencyService.addCoins(player, amount)
	-- Propósito: Sumar monedas a un jugador.
	-- Precondiciones:
	--   1. player válido; amount > 0.
	-- Ubicación: ServerScriptService/CurrencyService
	-- Retorna: number (nuevo total)
	local coins = getLeaderstat(player)
	coins.Value = coins.Value + amount
	return coins.Value
end

function CurrencyService.spendCoins(player, amount)
	-- Propósito: Gastar monedas si el jugador tiene suficientes.
	-- Precondiciones:
	--   1. player válido; amount > 0.
	-- Ubicación: ServerScriptService/CurrencyService
	-- Retorna: boolean (true si se pudo gastar)
	local coins = getLeaderstat(player)
	if coins.Value < amount then return false end
	coins.Value = coins.Value - amount
	return true
end

-- Inicializar leaderstats.
for _, player in ipairs(Players:GetPlayers()) do
	getLeaderstat(player)
end
Players.PlayerAdded:Connect(getLeaderstat)

-- Spawnear monedas visibles desde el arranque.
for _ = 1, curCfg.INITIAL_COINS do
	spawnCoin()
end

-- Bucle de respawn: repone monedas a medida que se recolectan.
task.spawn(function()
	while true do
		task.wait(curCfg.SPAWN_INTERVAL)
		spawnCoin()
	end
end)

_G.ZB = _G.ZB or {}
_G.ZB.CurrencyService = CurrencyService
