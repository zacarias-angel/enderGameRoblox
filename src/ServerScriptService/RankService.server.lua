-- Tipo: Script
-- Ubicacion: ServerScriptService/RankService
-- Contexto: Servidor

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local rankCfg = Config.Rank
local curCfg = Config.Currency

local MAX_LISTED = 50
local playerStats = {}

local function ensureStats(player)
	if not playerStats[player] then
		playerStats[player] = { eliminations = 0, limbsFrozen = 0, matchesPlayed = 0 }
	end
	return playerStats[player]
end

local function getCoins(player)
	local stats = player:FindFirstChild("leaderstats")
	if stats then
		local coins = stats:FindFirstChild(curCfg.LEADERSTAT)
		if coins then return coins.Value end
	end
	return 0
end

local function getPlaca(name)
	local folder = workspace:FindFirstChild("placas")
	if not folder then return nil end
	return folder:FindFirstChild(name)
end

local LIST_NAME = 'RankList'

local function getGui(placa)
	if not placa then return nil end
	return placa:FindFirstChildOfClass('SurfaceGui') or placa:FindFirstChildOfClass('BillboardGui')
end

local function ensureRankList(gui)
	if not gui then return nil end
	local oldLabel = gui:FindFirstChild('RankLabel', true)
	if oldLabel then oldLabel:Destroy() end
	local existing = gui:FindFirstChild(LIST_NAME, true)
	if existing then return existing end
	local container = gui:FindFirstChild('Frame') or gui
	local list = Instance.new('ScrollingFrame')
	list.Name = LIST_NAME
	list.Position = UDim2.new(0, 10, 0, 58)
	list.Size = UDim2.new(0, 200, 0, 98)
	list.BackgroundTransparency = 1
	list.BorderSizePixel = 0
	list.ScrollingDirection = Enum.ScrollingDirection.Y
	list.AutomaticCanvasSize = Enum.AutomaticSize.Y
	list.CanvasSize = UDim2.new(0, 200, 0, 0)
	list.ScrollBarThickness = 4
	list.ScrollBarImageColor3 = Color3.fromRGB(90, 220, 255)
	list.ClipsDescendants = true
	list.Selectable = false
	list.Parent = container
	local layout = Instance.new('UIListLayout')
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, 2)
	layout.Parent = list
	return list
end

local function clearList(list)
	for _, child in ipairs(list:GetChildren()) do
		if child:IsA('GuiObject') then child:Destroy() end
	end
end

local function addRow(list, rank, name, value, color)
	local row = Instance.new('Frame')
	row.Name = 'Row'
	row.Size = UDim2.new(1, 0, 0, 16)
	row.BackgroundTransparency = (rank % 2 == 0) and 0.85 or 0.95
	row.BackgroundColor3 = Color3.fromRGB(20, 24, 34)
	row.BorderSizePixel = 0
	row.LayoutOrder = rank
	row.Parent = list

	local pos = Instance.new('TextLabel')
	pos.Name = 'Pos'
	pos.Position = UDim2.new(0, 2, 0, 0)
	pos.Size = UDim2.new(0, 28, 1, 0)
	pos.BackgroundTransparency = 1
	pos.BorderSizePixel = 0
	pos.Text = '#' .. tostring(rank)
	pos.TextXAlignment = Enum.TextXAlignment.Left
	pos.TextSize = 13
	pos.Font = Enum.Font.GothamBold
	pos.TextColor3 = color
	pos.Parent = row

	local nameLabel = Instance.new('TextLabel')
	nameLabel.Name = 'Name'
	nameLabel.Position = UDim2.new(0, 32, 0, 0)
	nameLabel.Size = UDim2.new(1, -60, 1, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.BorderSizePixel = 0
	nameLabel.Text = name
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.TextSize = 13
	nameLabel.Font = Enum.Font.Gotham
	nameLabel.TextColor3 = Color3.fromRGB(230, 235, 240)
	nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
	nameLabel.Parent = row

	local val = Instance.new('TextLabel')
	val.Name = 'Val'
	val.Position = UDim2.new(1, -48, 0, 0)
	val.Size = UDim2.new(0, 48, 1, 0)
	val.BackgroundTransparency = 1
	val.BorderSizePixel = 0
	val.Text = tostring(value)
	val.TextXAlignment = Enum.TextXAlignment.Right
	val.TextSize = 13
	val.Font = Enum.Font.GothamBold
	val.TextColor3 = Color3.fromRGB(90, 220, 255)
	val.Parent = row
end

local function renderRanking(list, ranked)
	clearList(list)
	if #ranked == 0 then
		local empty = Instance.new('TextLabel')
		empty.Name = 'Empty'
		empty.Size = UDim2.new(1, 0, 0, 18)
		empty.BackgroundTransparency = 1
		empty.BorderSizePixel = 0
		empty.Text = 'Esperando jugadores...'
		empty.TextSize = 13
		empty.Font = Enum.Font.Gotham
		empty.TextColor3 = Color3.fromRGB(160, 170, 180)
		empty.TextXAlignment = Enum.TextXAlignment.Left
		empty.Parent = list
		return
	end
	local topColors = {
		Color3.fromRGB(255, 215, 90),
		Color3.fromRGB(200, 205, 215),
		Color3.fromRGB(210, 140, 80),
	}
	local normalColor = Color3.fromRGB(180, 190, 200)
	for i = 1, math.min(MAX_LISTED, #ranked) do
		local entry = ranked[i]
		local color = topColors[i] or normalColor
		addRow(list, i, entry.player.Name, entry.value, color)
	end
end

local function rankedPlayers(categoryKey)
	local list = {}
	if categoryKey == "coins" then
		for _, player in ipairs(Players:GetPlayers()) do
			table.insert(list, { player = player, value = getCoins(player) })
		end
	else
		for player, stats in pairs(playerStats) do
			if player.Parent then
				table.insert(list, { player = player, value = stats[categoryKey] or 0 })
			end
		end
	end
	table.sort(list, function(a, b)
		if a.value ~= b.value then
			return a.value > b.value
		end
		return a.player.UserId < b.player.UserId
	end)
	return list
end

local function updatePlacas()
	for index, cat in ipairs(rankCfg.CATEGORIES) do
		local placa = getPlaca(rankCfg.PLACA_NAMES[index])
		if placa then
			local gui = getGui(placa)
			local titleLabel = gui and gui:FindFirstChild('RankTitle', true)
			if titleLabel then
				titleLabel.Text = cat.title
			end
			local list = ensureRankList(gui)
			if list then
				renderRanking(list, rankedPlayers(cat.key))
			end
		end
	end
end

local RankService = {}

function RankService.addScore(player, reason)
	if not player or not player.Parent then return end
	local stats = ensureStats(player)
	if reason == "elimination" then
		stats.eliminations = stats.eliminations + 1
	elseif reason == "limbFreeze" then
		stats.limbsFrozen = stats.limbsFrozen + 1
	end
end

function RankService.addMatch(player)
	if not player or not player.Parent then return end
	local stats = ensureStats(player)
	stats.matchesPlayed = stats.matchesPlayed + 1
end

function RankService.getStats(player)
	local stats = ensureStats(player)
	return {
		eliminations = stats.eliminations,
		limbsFrozen = stats.limbsFrozen,
		matchesPlayed = stats.matchesPlayed,
	}
end

function RankService.applyStats(player, incoming)
	if not player or not player.Parent then return end
	local stats = ensureStats(player)
	if type(incoming) ~= "table" then return end
	stats.eliminations = math.max(0, math.floor(tonumber(incoming.eliminations) or 0))
	stats.limbsFrozen = math.max(0, math.floor(tonumber(incoming.limbsFrozen) or 0))
	stats.matchesPlayed = math.max(0, math.floor(tonumber(incoming.matchesPlayed) or 0))
end

function RankService.onModeStarted(mode)
end

task.spawn(function()
	while true do
		task.wait(rankCfg.UPDATE_INTERVAL)
		updatePlacas()
	end
end)

Players.PlayerRemoving:Connect(function(player)
	playerStats[player] = nil
end)

_G.ZB = _G.ZB or {}
_G.ZB.RankService = RankService
