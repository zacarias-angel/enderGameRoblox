-- Tipo: Script
-- Ubicación: ServerScriptService/CurrencyService
-- Contexto: Servidor

--[[
	CurrencyService
	Sistema de monedas del juego. Las monedas sirven para comprar/mejorar
	items (pendiente). Este servicio:
	- Crea el leaderstat "Monedas" en cada jugador.
	- Spawnea monedas en el lobby y en la arena (~100 por hora).
	- Detecta cuando un jugador toca una moneda y la recolecta.

	Expone API: _G.ZB.CurrencyService.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local curCfg = Config.Currency

local activeCoins = {}  -- [coin] = true

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

local function getRandomSpawnPosition()
	-- Propósito: Obtener una posición aleatoria en el lobby o arena.
	-- Precondiciones: ninguna.
	-- Ubicación: ServerScriptService/CurrencyService
	-- Retorna: Vector3
	-- Lobby (piso)
	local piso = workspace:FindFirstChild("piso")
	if piso then
		local pos = piso.Position
		local hw = piso.Size.X / 2
		local hd = piso.Size.Z / 2
		local top = pos.Y + piso.Size.Y / 2

		-- 50% lobby, 50% arena
		if math.random() < 0.5 then
			local x = pos.X + (math.random() * 2 - 1) * (hw - 10)
			local z = pos.Z + (math.random() * 2 - 1) * (hd - 10)
			return Vector3.new(x, top + curCfg.SPAWN_HEIGHT, z)
		end
	end

	-- Arena
	local arena = workspace:FindFirstChild("Arena")
	if arena then
		local center = Vector3.zero
		local spawns = {}
		for _, child in ipairs(arena:GetDescendants()) do
			if child:IsA("BasePart") then
				table.insert(spawns, child.Position)
			end
		end
		if #spawns > 0 then
			center = spawns[math.random(#spawns)]
			return center + Vector3.new(
				(math.random() * 2 - 1) * 20,
				curCfg.SPAWN_HEIGHT,
				(math.random() * 2 - 1) * 20
			)
		end
	end

	-- Fallback: origen
	return Vector3.new(math.random() * 40 - 20, 5, math.random() * 40 - 20)
end

local function spawnCoin()
	-- Propósito: Crear una moneda en una posición aleatoria.
	-- Precondiciones: ninguna.
	-- Ubicación: ServerScriptService/CurrencyService
	-- Retorna: nil
	local coin = Instance.new("Part")
	coin.Name = curCfg.COIN_NAME
	coin.Anchored = true
	coin.CanCollide = false
	coin.CanQuery = false
	coin.CastShadow = false
	coin.Shape = Enum.PartType.Ball
	coin.Size = curCfg.COIN_SIZE
	coin.Color = curCfg.COIN_COLOR
	coin.Material = Enum.Material.Neon
	coin.CFrame = CFrame.new(getRandomSpawnPosition())
	coin.Parent = getCoinFolder()

	-- Luz para que sea visible
	local light = Instance.new("PointLight")
	light.Color = curCfg.COIN_COLOR
	light.Range = 8
	light.Brightness = 1.5
	light.Parent = coin

	-- Recolección por toque
	coin.Touched:Connect(function(hit)
		local character = hit.Parent
		if not character then return end
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if not humanoid then return end
		local player = Players:GetPlayerFromCharacter(character)
		if not player then return end

		-- Recolectar
		local coins = getLeaderstat(player)
		coins.Value = coins.Value + curCfg.COIN_VALUE

		-- Efecto: destello breve antes de destruir
		coin.CanCollide = false
		coin:Destroy()
		activeCoins[coin] = nil
	end)

	activeCoins[coin] = true

	-- Auto-limpiar monedas que exceden el máximo concurrente
	if #activeCoins > curCfg.MAX_CONCURRENT_COINS then
		-- Eliminar la moneda más antigua
		for oldCoin in pairs(activeCoins) do
			if oldCoin ~= coin then
				oldCoin:Destroy()
				activeCoins[oldCoin] = nil
				break
			end
		end
	end
end

local CurrencyService = {}

function CurrencyService.getCoins(player)
	-- Propósito: Obtener las monedas actuales de un jugador.
	-- Precondiciones:
	--   1. player es un Player válido.
	-- Ubicación: ServerScriptService/CurrencyService
	-- Retorna: number
	local coins = getLeaderstat(player)
	return coins.Value
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

-- Inicializar leaderstats para jugadores existentes
for _, player in ipairs(Players:GetPlayers()) do
	getLeaderstat(player)
end
Players.PlayerAdded:Connect(function(player)
	getLeaderstat(player)
end)

-- Bucle de spawn de monedas (~100 por hora)
task.spawn(function()
	while true do
		task.wait(curCfg.SPAWN_INTERVAL)
		spawnCoin()
	end
end)

_G.ZB = _G.ZB or {}
_G.ZB.CurrencyService = CurrencyService
