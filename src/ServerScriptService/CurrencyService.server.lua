-- Tipo: Script
-- Ubicacion: ServerScriptService/CurrencyService
-- Contexto: Servidor

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local curCfg = Config.Currency

local activeCoins = {}

local function getCoinFolder()
	local folder = workspace:FindFirstChild("Coins")
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "Coins"
		folder.Parent = workspace
	end
	return folder
end

local function getLeaderstat(player)
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
	if math.random() < 0.5 then
		local lobby = randomLobbyPosition()
		if lobby then return lobby end
	end
	local arena = randomArenaPosition()
	if arena then return arena end
	local lobby = randomLobbyPosition()
	if lobby then return lobby end
	return Vector3.new(0, 10, 0)
end

local function spawnCoin()
	if #activeCoins >= curCfg.MAX_CONCURRENT_COINS then return end
	local coin = Instance.new("Part")
	coin.Name = curCfg.COIN_NAME
	coin.Anchored = true
	coin.CanCollide = true
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
		local missionService = _G.ZB and _G.ZB.MissionService
		if missionService then
			missionService.recordProgress(player, "coinsCollected", curCfg.COIN_VALUE)
		end
		activeCoins[coin] = nil
		coin:Destroy()
	end)

	activeCoins[coin] = true
end

local CurrencyService = {}

function CurrencyService.getCoins(player)
	return getLeaderstat(player).Value
end

function CurrencyService.setCoins(player, amount)
	local coins = getLeaderstat(player)
	coins.Value = math.max(0, math.floor(tonumber(amount) or 0))
	return coins.Value
end

function CurrencyService.addCoins(player, amount)
	local coins = getLeaderstat(player)
	coins.Value = coins.Value + amount
	return coins.Value
end

function CurrencyService.spendCoins(player, amount)
	local coins = getLeaderstat(player)
	if coins.Value < amount then return false end
	coins.Value = coins.Value - amount
	return true
end

for _, player in ipairs(Players:GetPlayers()) do getLeaderstat(player) end
Players.PlayerAdded:Connect(getLeaderstat)

for _ = 1, curCfg.INITIAL_COINS do
	spawnCoin()
end

task.spawn(function()
	while true do
		task.wait(curCfg.SPAWN_INTERVAL)
		spawnCoin()
	end
end)

_G.ZB = _G.ZB or {}
_G.ZB.CurrencyService = CurrencyService
