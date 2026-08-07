-- Tipo: Script
-- Ubicación: ServerScriptService/RankService
-- Contexto: Servidor

--[[
	RankService
	Sistema de ranking y puntuación que se muestra en las placas del workspace.
	Las placas están en Workspace > placas > Placa1 / Placa2 / Placa3.
	Cada placa debe ser un Part con un SurfaceGui (Face = Front) que tenga un
	TextLabel llamado "RankLabel".

	Puntuación:
	- +10 por eliminación de enemigo (ELIMINATE)
	- +3 por congelar una extremidad enemiga (FREEZE_*)

	Actualiza las placas cada Config.Rank.UPDATE_INTERVAL segundos con el
	top 3 de jugadores.
	Expone API vía _G.ZB.RankService.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local rankCfg = Config.Rank

local playerScores = {}  -- [player] = { score, eliminations, limbsFrozen }

local function getPlaca(name)
	-- Propósito: Encontrar una placa en el workspace.
	-- Precondiciones:
	--   1. name es el nombre de la placa (ej. "Placa1").
	-- Ubicación: ServerScriptService/RankService
	-- Retorna: Instance o nil
	local folder = workspace:FindFirstChild("placas")
	if not folder then return nil end
	return folder:FindFirstChild(name)
end

local function getLabel(placa)
	-- Propósito: Obtener el TextLabel "RankLabel" dentro de la placa.
	-- Precondiciones:
	--   1. placa es un Part con SurfaceGui.
	-- Ubicación: ServerScriptService/RankService
	-- Retorna: TextLabel o nil
	if not placa then return nil end
	local gui = placa:FindFirstChildOfClass("SurfaceGui")
	if not gui then return nil end
	return gui:FindFirstChild("RankLabel")
end

local function ensureScore(player)
	-- Propósito: Obtener/crear la entrada de puntuación de un jugador.
	-- Precondiciones:
	--   1. player es un Player válido.
	-- Ubicación: ServerScriptService/RankService
	-- Retorna: table { score, eliminations, limbsFrozen }
	if not playerScores[player] then
		playerScores[player] = {
			score = 0,
			eliminations = 0,
			limbsFrozen = 0,
		}
	end
	return playerScores[player]
end

local function addPoints(player, points)
	-- Propósito: Sumar puntos a un jugador.
	-- Precondiciones:
	--   1. player es un Player válido.
	--   2. points es un número positivo.
	-- Ubicación: ServerScriptService/RankService
	-- Retorna: number (nueva puntuación total)
	local entry = ensureScore(player)
	entry.score = entry.score + points
	return entry.score
end

local function getTopPlayers(count)
	-- Propósito: Obtener los N jugadores con mayor puntuación.
	-- Precondiciones:
	--   1. count es el número de posiciones (1..N).
	-- Ubicación: ServerScriptService/RankService
	-- Retorna: table de { player, score } ordenada descendente.
	local list = {}
	for player, entry in pairs(playerScores) do
		if player.Parent then
			table.insert(list, { player = player, score = entry.score, entry = entry })
		end
	end
	table.sort(list, function(a, b)
		return a.score > b.score
	end)
	local result = {}
	for i = 1, math.min(count, #list) do
		result[i] = list[i]
	end
	return result
end

local function updatePlacas()
	-- Propósito: Escribir el top 3 en las placas del workspace.
	-- Precondiciones:
	--   1. Las placas existen en workspace/placas/.
	-- Ubicación: ServerScriptService/RankService
	-- Retorna: nil
	local top = getTopPlayers(rankCfg.MAX_PLACES)

	for index = 1, rankCfg.MAX_PLACES do
		local placa = getPlaca(rankCfg.PLACA_NAMES[index])
		if not placa then
			-- Placa no encontrada: no es error, simplemente no se encontró.
			continue
		end
		local label = getLabel(placa)
		if not label then
			continue
		end

		local entry = top[index]
		if entry then
			local kills = entry.entry.eliminations
			label.Text = string.format(
				"#%d  %s\n%d pts  |  %d kills",
				index,
				entry.player.Name,
				entry.score,
				kills
			)
		else
			label.Text = string.format("#%d  ---\n0 pts  |  0 kills", index)
		end
	end
end

local function fullReset()
	-- Propósito: Limpiar todas las puntuaciones al volver al lobby.
	-- Precondiciones: ninguna.
	-- Ubicación: ServerScriptService/RankService
	-- Retorna: nil
	for _, entry in pairs(playerScores) do
		entry.score = 0
		entry.eliminations = 0
		entry.limbsFrozen = 0
	end
	updatePlacas()
end

local RankService = {}

function RankService.addScore(player, reason)
	-- Propósito: Sumar puntos con registro de la razón.
	-- Precondiciones:
	--   1. player es un Player válido.
	--   2. reason es "elimination" o "limbFreeze".
	-- Ubicación: ServerScriptService/RankService
	-- Retorna: nil
	if not player or not player.Parent then return end

	local entry = ensureScore(player)
	if reason == "elimination" then
		entry.eliminations = entry.eliminations + 1
		addPoints(player, rankCfg.POINTS_PER_ELIMINATION)
	elseif reason == "limbFreeze" then
		entry.limbsFrozen = entry.limbsFrozen + 1
		addPoints(player, rankCfg.POINTS_PER_LIMB_FREEZE)
	end
end

function RankService.onModeStarted(mode)
	-- Propósito: Llamado por GameModeService al entrar en batalla/duelo.
	-- Precondiciones:
	--   1. mode es BATTLE o DUEL.
	-- Ubicación: ServerScriptService/RankService
	-- Retorna: nil
	-- Resetear puntuaciones al iniciar una partida nueva.
	fullReset()
end

-- Hookear en el FreezeService para sumar puntos automáticamente.
-- Esperamos a que FreezeService esté listo y lo envolvemos.
task.spawn(function()
	while not (_G.ZB and _G.ZB.FreezeService) do
		task.wait(0.5)
	end

	local originalApply = _G.ZB.FreezeService.apply
	_G.ZB.FreezeService.apply = function(character, hitResult)
		local result = originalApply(character, hitResult)
		if result then
			-- El atacante se determina en ShootingService; aquí solo
			-- registramos que hubo un efecto sobre el objetivo.
			-- La atribución de puntos se hace desde ShootingService.
		end
		return result
	end
end)

-- Iniciar bucle de actualización de placas.
task.spawn(function()
	while true do
		task.wait(rankCfg.UPDATE_INTERVAL)
		updatePlacas()
	end
end)

-- Limpiar al salir un jugador.
Players.PlayerRemoving:Connect(function(player)
	playerScores[player] = nil
end)

_G.ZB = _G.ZB or {}
_G.ZB.RankService = RankService
