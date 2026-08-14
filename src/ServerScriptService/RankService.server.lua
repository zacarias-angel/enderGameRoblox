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

	Debajo del título, lista de jugadores con formato:
		#pos  Nombre  [valor]

	Expone API: _G.ZB.RankService.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local rankCfg = Config.Rank
local curCfg = Config.Currency

local MAX_LISTED = 5  -- Máximo de jugadores mostrados por placa

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

local function getLabels(placa)
	-- Propósito: Obtener los TextLabels "RankTitle" y "RankLabel" de la placa.
	-- Precondiciones:
	--   1. placa tiene SurfaceGui (o BillboardGui).
	-- Ubicación: ServerScriptService/RankService
	-- Retorna: (titleLabel, valueLabel) o (nil, nil)
	if not placa then return nil, nil end
	local gui = placa:FindFirstChildOfClass("SurfaceGui") or placa:FindFirstChildOfClass("BillboardGui")
	if not gui then return nil, nil end
	return gui:FindFirstChild("RankTitle"), gui:FindFirstChild("RankLabel")
end

local function rankedPlayers(categoryKey)
	-- Propósito: Obtener la lista de jugadores ordenada por la categoría.
	-- Precondiciones:
	--   1. categoryKey es "eliminations", "matchesPlayed" o "coins".
	-- Ubicación: ServerScriptService/RankService
	-- Retorna: table de { player, value } ordenada descendente.
	local list = {}
	for player, stats in pairs(playerStats) do
		if player.Parent then
			local value
			if categoryKey == "coins" then
				value = getCoins(player)
			else
				value = stats[categoryKey] or 0
			end
			table.insert(list, { player = player, value = value })
		end
	end
	table.sort(list, function(a, b)
		return a.value > b.value
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
			local titleLabel, valueLabel = getLabels(placa)
			if titleLabel then
				titleLabel.Text = cat.title
			end
			if valueLabel then
				local ranked = rankedPlayers(cat.key)
				local lines = {}
				for i = 1, math.min(MAX_LISTED, #ranked) do
					local entry = ranked[i]
					table.insert(lines, string.format("#%d %s [%d]", i, entry.player.Name, entry.value))
				end
				if #lines == 0 then
					valueLabel.Text = "Esperando jugadores..."
				else
					valueLabel.Text = table.concat(lines, "\n")
				end
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
