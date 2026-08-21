-- Tipo: Script
-- Ubicación: ServerScriptService/RankService
-- Contexto: Servidor

--[[
	RankService
	Sistema de ranking que se muestra en las 3 placas del workspace.
	Las placas están en Workspace > placas > placas1 / placas2 / placas3.

	Cada placa muestra una categoría (top jugadores):
	- placas1 = "CONGELADOS" (más enemigos congelados)
	- placas2 = "PARTIDAS"  (más partidas jugadas)
	- placas3 = "MONEDAS"   (más monedas recolectadas)

	Debajo del título se renderiza una lista estilo ranking (top 50) con
	filas alineadas: posición (#1) a la izquierda, nombre, y valor a la
	derecha. La lista vive en un ScrollingFrame para poder hacer scroll.

	Expone API: _G.ZB.RankService.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local rankCfg = Config.Rank
local curCfg = Config.Currency

local MAX_LISTED = 50  -- Top de jugadores mostrados por placa
local LIST_NAME = "RankList"

local playerStats = {}  -- [player] = { eliminations, limbsFrozen, matchesPlayed }

local function ensureStats(player)
	-- Propósito: Obtener/crear las estadísticas de un jugador.
	-- Precondiciones:
	--   1. player es un Player válido.
	-- Ubicación: ServerScriptService/RankService
	-- Retorna: table { eliminations, limbsFrozen, matchesPlayed }
	if not playerStats[player] then
		playerStats[player] = {
			eliminations = 0,
			limbsFrozen = 0,
			matchesPlayed = 0,
		}
	end
	return playerStats[player]
end

local function getCoins(player)
	-- Propósito: Obtener las monedas de un jugador (del leaderstat).
	-- Precondiciones:
	--   1. player es un Player válido.
	-- Ubicación: ServerScriptService/RankService
	-- Retorna: number
	local stats = player:FindFirstChild("leaderstats")
	if stats then
		local coins = stats:FindFirstChild(curCfg.LEADERSTAT)
		if coins then return coins.Value end
	end
	return 0
end

local function getPlaca(name)
	-- Propósito: Encontrar una placa en workspace/placas.
	-- Precondiciones:
	--   1. name es el nombre de la placa.
	-- Ubicación: ServerScriptService/RankService
	-- Retorna: Instance o nil
	local folder = workspace:FindFirstChild("placas")
	if not folder then return nil end
	return folder:FindFirstChild(name)
end

local function getGui(placa)
	-- Propósito: Obtener la SurfaceGui (o BillboardGui) de una placa.
	-- Precondiciones:
	--   1. placa es un Model/BasePart con GUI.
	-- Ubicación: ServerScriptService/RankService
	-- Retorna: Instance o nil
	if not placa then return nil end
	return placa:FindFirstChildOfClass("SurfaceGui") or placa:FindFirstChildOfClass("BillboardGui")
end

local function ensureRankList(gui)
	-- Propósito: Obtener/crear el ScrollingFrame "RankList" donde se pintan
	--            las filas del ranking. Elimina el antiguo TextLabel "RankLabel".
	-- Precondiciones:
	--   1. gui es una SurfaceGui/BillboardGui de una placa.
	-- Ubicación: ServerScriptService/RankService
	-- Retorna: ScrollingFrame o nil
	if not gui then return nil end

	local oldLabel = gui:FindFirstChild("RankLabel", true)
	if oldLabel then
		oldLabel:Destroy()
	end

	local existing = gui:FindFirstChild(LIST_NAME, true)
	if existing then return existing end

	local container = gui:FindFirstChild("Frame") or gui

	local list = Instance.new("ScrollingFrame")
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

	local layout = Instance.new("UIListLayout")
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, 2)
	layout.Parent = list

	return list
end

local function clearList(list)
	-- Propósito: Vaciar el ScrollingFrame del ranking.
	-- Precondiciones:
	--   1. list es un ScrollingFrame.
	-- Ubicación: ServerScriptService/RankService
	-- Retorna: nil
	for _, child in ipairs(list:GetChildren()) do
		if child:IsA("GuiObject") then
			child:Destroy()
		end
	end
end

local function addRow(list, rank, name, value, color)
	-- Propósito: Crear una fila del ranking (posición + nombre + valor).
	-- Precondiciones:
	--   1. list es el ScrollingFrame destino.
	--   2. rank es un entero >= 1.
	-- Ubicación: ServerScriptService/RankService
	-- Retorna: nil
	local row = Instance.new("Frame")
	row.Name = "Row"
	row.Size = UDim2.new(1, 0, 0, 16)
	row.BackgroundTransparency = (rank % 2 == 0) and 0.85 or 0.95
	row.BackgroundColor3 = Color3.fromRGB(20, 24, 34)
	row.BorderSizePixel = 0
	row.LayoutOrder = rank
	row.Parent = list

	local pos = Instance.new("TextLabel")
	pos.Name = "Pos"
	pos.Position = UDim2.new(0, 2, 0, 0)
	pos.Size = UDim2.new(0, 28, 1, 0)
	pos.BackgroundTransparency = 1
	pos.BorderSizePixel = 0
	pos.Text = "#" .. tostring(rank)
	pos.TextXAlignment = Enum.TextXAlignment.Left
	pos.TextSize = 13
	pos.Font = Enum.Font.GothamBold
	pos.TextColor3 = color
	pos.Parent = row

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "Name"
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

	local val = Instance.new("TextLabel")
	val.Name = "Val"
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
	-- Propósito: Pintar el top (MAX_LISTED) dentro del ScrollingFrame.
	-- Precondiciones:
	--   1. list es el ScrollingFrame destino.
	--   2. ranked es una lista ordenada de { player, value }.
	-- Ubicación: ServerScriptService/RankService
	-- Retorna: nil
	clearList(list)

	if #ranked == 0 then
		local empty = Instance.new("TextLabel")
		empty.Name = "Empty"
		empty.Size = UDim2.new(1, 0, 0, 18)
		empty.BackgroundTransparency = 1
		empty.BorderSizePixel = 0
		empty.Text = "Esperando jugadores..."
		empty.TextSize = 13
		empty.Font = Enum.Font.Gotham
		empty.TextColor3 = Color3.fromRGB(160, 170, 180)
		empty.TextXAlignment = Enum.TextXAlignment.Left
		empty.Parent = list
		return
	end

	-- Oro, plata y bronce para los 3 primeros; gris para el resto.
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
	-- Propósito: Obtener la lista de jugadores ordenada por la categoría.
	-- Precondiciones:
	--   1. categoryKey es "eliminations", "matchesPlayed" o "coins".
	-- Ubicación: ServerScriptService/RankService
	-- Retorna: table de { player, value } ordenada descendente.
	local list = {}

	if categoryKey == "coins" then
		-- Monedas: leer de TODOS los jugadores conectados (leaderstat),
		-- no solo de los que hayan jugado una partida.
		for _, player in ipairs(Players:GetPlayers()) do
			local value = getCoins(player)
			table.insert(list, { player = player, value = value })
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
	-- Propósito: Escribir cada categoría en su placa.
	-- Precondiciones: ninguna.
	-- Ubicación: ServerScriptService/RankService
	-- Retorna: nil
	for index, cat in ipairs(rankCfg.CATEGORIES) do
		local placa = getPlaca(rankCfg.PLACA_NAMES[index])
		if placa then
			local gui = getGui(placa)
			local titleLabel = gui and gui:FindFirstChild("RankTitle", true)
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
	-- Propósito: Registrar eliminación o congelación de extremidad.
	-- Precondiciones:
	--   1. player válido; reason "elimination" o "limbFreeze".
	-- Ubicación: ServerScriptService/RankService
	-- Retorna: nil
	if not player or not player.Parent then return end
	local stats = ensureStats(player)
	if reason == "elimination" then
		stats.eliminations = stats.eliminations + 1
	elseif reason == "limbFreeze" then
		stats.limbsFrozen = stats.limbsFrozen + 1
	end
end

function RankService.addMatch(player)
	-- Propósito: Registrar que el jugador jugó una partida.
	-- Precondiciones:
	--   1. player es un Player válido.
	-- Ubicación: ServerScriptService/RankService
	-- Retorna: nil
	if not player or not player.Parent then return end
	local stats = ensureStats(player)
	stats.matchesPlayed = stats.matchesPlayed + 1
end

function RankService.onModeStarted(mode)
	-- Propósito: Llamado al iniciar una partida.
	-- Precondiciones:
	--   1. mode es BATTLE o DUEL.
	-- Ubicación: ServerScriptService/RankService
	-- Retorna: nil
end

-- Bucle de actualización de placas.
task.spawn(function()
	while true do
		task.wait(rankCfg.UPDATE_INTERVAL)
		updatePlacas()
	end
end)

-- Limpiar al salir un jugador.
Players.PlayerRemoving:Connect(function(player)
	playerStats[player] = nil
end)

_G.ZB = _G.ZB or {}
_G.ZB.RankService = RankService
