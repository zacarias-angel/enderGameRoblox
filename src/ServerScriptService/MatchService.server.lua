-- Tipo: Script
-- Ubicación: ServerScriptService/MatchService
-- Contexto: Servidor

--[[
	MatchService
	Sistema de partidas automáticas con equipos balanceados y timer.
	Flujo de una partida:

	  LOBBY → COUNTDOWN → ACTIVE → ENDING → RESET → LOBBY ...

	- LOBBY: todos esperan en el lobby con gravedad normal.
	- COUNTDOWN: cuenta regresiva global. Al terminar, entran juntos todos los
	             jugadores conectados en ese momento.
	- ACTIVE: partida en curso. Jugadores teleportados a spawns. Gravedad 0.
	- ENDING: se anuncia el ganador. 3s de pausa.
	- RESET: se devuelve a todos al lobby, gravedad normal. Se limpia el
	         estado. Luego vuelve a LOBBY y, si hay suficientes jugadores,
	         arranca otra cuenta regresiva.

	RemoteEvents: JoinMatchRequest (compat), MatchStateChanged (s→c).
	API: _G.ZB.MatchService.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local matchCfg = Config.Match
local modeCfg = Config.GameMode

local function ensureRemote(name)
	-- Propósito: Obtener/crear un RemoteEvent en ReplicatedStorage/RemoteEvents.
	-- Precondiciones:
	--   1. name es un string no vacío.
	-- Ubicación: ServerScriptService/MatchService
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

local joinRequest = ensureRemote("JoinMatchRequest")
local matchStateChanged = ensureRemote("MatchStateChanged")
local battleOptOutChanged = ensureRemote("BattleOptOutChanged")

-- ===== Estado global =====
local currentState = matchCfg.STATE_LOBBY
local playerTeam = {}      -- [player] = "Azul" | "Rojo"
local matchTimer = 0       -- tiempo transcurrido desde ACTIVE
local countdownTimer = 0   -- tiempo restante de cuenta regresiva
local resetCountdown = 0   -- tiempo restante para volver al lobby
local matchActive = false
local teamEliminated = {}  -- [team] = true si el equipo fue aniquilado
local finalizing = false      -- true durante el cronómetro final
local finalizeCountdown = 0   -- segundos restantes del cronómetro final
local finalizeWinner = nil    -- equipo ganador cuando termina el cronómetro
local dummyModel = nil        -- NPC dummy en la arena
local dummyTeam = matchCfg.TEAM_ROJO  -- el dummy va al equipo Rojo
local broadcastState
local PARTICIPANT_ATTRIBUTE = "BattleParticipant"

local function setBattleParticipant(player, isParticipant)
	if player and player.Parent then
		player:SetAttribute(PARTICIPANT_ATTRIBUTE, isParticipant == true)
	end
end

local function isPlayerOptedOut(player)
	return player:GetAttribute(matchCfg.OPT_OUT_ATTRIBUTE) == true
end

local function getConnectedPlayers()
	local players = {}
	for _, player in ipairs(Players:GetPlayers()) do
		if player.Parent then
			table.insert(players, player)
		end
	end
	table.sort(players, function(a, b)
		return a.UserId < b.UserId
	end)
	return players
end

local function getEligiblePlayers()
	local eligible = {}
	for _, player in ipairs(getConnectedPlayers()) do
		if not isPlayerOptedOut(player) then
			table.insert(eligible, player)
		end
	end
	return eligible
end

local function canStartRound()
	return #getEligiblePlayers() >= matchCfg.MIN_PLAYERS_TO_START
end

local function countActiveParticipants()
	local count = 0
	for player, _ in pairs(playerTeam) do
		if player.Parent then
			count = count + 1
		end
	end
	return count
end

local function startCountdown()
	if currentState ~= matchCfg.STATE_LOBBY then return end
	if not canStartRound() then return end

	currentState = matchCfg.STATE_COUNTDOWN
	countdownTimer = matchCfg.COUNTDOWN
	broadcastState()
end

local function assignTeamsForPlayers(players)
	playerTeam = {}
	for index, player in ipairs(players) do
		if index % 2 == 1 then
			playerTeam[player] = matchCfg.TEAM_AZUL
		else
			playerTeam[player] = matchCfg.TEAM_ROJO
		end
	end
end

local function findDummy()
	-- Propósito: Encontrar el dummy NPC (Humanoid sin Player) en el workspace.
	-- Precondiciones: ninguna.
	-- Ubicación: ServerScriptService/MatchService
	-- Retorna: Model o nil
	for _, inst in ipairs(workspace:GetDescendants()) do
		if inst:IsA("Humanoid") and inst.Parent and inst.Parent:IsA("Model") then
			local model = inst.Parent
			local player = Players:GetPlayerFromCharacter(model)
			if not player then
				return model
			end
		end
	end
	return nil
end

local function isDummyAlive()
	-- Propósito: Saber si el dummy está vivo (no eliminado).
	-- Precondiciones: ninguna.
	-- Ubicación: ServerScriptService/MatchService
	-- Retorna: boolean
	if not dummyModel or not dummyModel.Parent then return false end
	return dummyModel:GetAttribute("cubrirce") ~= true
end

local function countTeamPlayers(team)
	-- Propósito: Contar jugadores vivos en un equipo (incluye el dummy).
	-- Precondiciones:
	--   1. team es "Azul" o "Rojo".
	-- Ubicación: ServerScriptService/MatchService
	-- Retorna: number
	local count = 0
	for player, t in pairs(playerTeam) do
		if t == team and player.Parent then
			local PlayerState = _G.ZB and _G.ZB.PlayerState
			if PlayerState and PlayerState.isAlive(player) then
				count = count + 1
			end
		end
	end
	-- Dummy NPC
	if dummyModel and dummyTeam == team and isDummyAlive() then
		count = count + 1
	end
	return count
end

local function countAlivePlayers()
	local alive = 0
	for player, _ in pairs(playerTeam) do
		if player.Parent then
			local PlayerState = _G.ZB and _G.ZB.PlayerState
			if PlayerState and PlayerState.isAlive(player) then
				alive = alive + 1
			end
		end
	end
	if isDummyAlive() then
		alive = alive + 1
	end
	return alive
end

local function countTeamTotal(team)
	-- Propósito: Contar jugadores totales (vivos o no) en un equipo (incluye dummy).
	-- Precondiciones:
	--   1. team es "Azul" o "Rojo".
	-- Ubicación: ServerScriptService/MatchService
	-- Retorna: number
	local count = 0
	for _, t in pairs(playerTeam) do
		if t == team then count = count + 1 end
	end
	if dummyModel and dummyTeam == team then
		count = count + 1
	end
	return count
end

local function getSpawnPosition(player)
	-- Propósito: Calcular la posición de spawn según el equipo del jugador.
	-- Precondiciones:
	--   1. player tiene equipo asignado.
	-- Ubicación: ServerScriptService/MatchService
	-- Retorna: Vector3
	local team = playerTeam[player]
	if not team then return Vector3.zero end

	-- Buscar carpeta Arena en workspace.
	local arena = workspace:FindFirstChild("Arena")
	local spawnName = team == matchCfg.TEAM_AZUL and matchCfg.SPAWN_AZUL_NAME or matchCfg.SPAWN_ROJO_NAME

	-- 1) Si existe Arena/SpawnAzul o Arena/SpawnRojo, usar esa posición.
	if arena then
		local spawnPart = arena:FindFirstChild(spawnName)
		if spawnPart and spawnPart:IsA("BasePart") then
			return spawnPart.Position
		end
		-- También buscar directamente en workspace/Arena/TeamFolder/Spawn
		local teamFolder = arena:FindFirstChild(team)
		if teamFolder then
			local sp = teamFolder:FindFirstChild("Spawn")
			if sp and sp:IsA("BasePart") then
				return sp.Position
			end
		end
	end

	-- 2) Fallback: usar el portal como referencia + offset.
	local portal = workspace:FindFirstChild("Portal")
	local origin = portal and portal:IsA("BasePart") and portal.Position or Vector3.zero
	if team == matchCfg.TEAM_AZUL then
		return origin + matchCfg.ARENA_SPAWN_BLUE_OFFSET
	else
		return origin + matchCfg.ARENA_SPAWN_RED_OFFSET
	end
end

local function teleportToArena(player)
	-- Propósito: Teletransportar al jugador a su spawn de equipo.
	-- Precondiciones:
	--   1. player tiene personaje y equipo asignado.
	-- Ubicación: ServerScriptService/MatchService
	-- Retorna: nil
	local char = player.Character
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end

	local spawnPos = getSpawnPosition(player)
	root.CFrame = CFrame.new(spawnPos)
	root.AssemblyLinearVelocity = Vector3.zero
	root.AssemblyAngularVelocity = Vector3.zero
end

broadcastState = function()
	-- Propósito: Enviar el estado actual de la partida a todos los clientes.
	-- Precondiciones: ninguna.
	-- Ubicación: ServerScriptService/MatchService
	-- Retorna: nil
	local payload = {
		state = currentState,
		matchTimer = matchTimer,
		countdown = countdownTimer,
		resetCountdown = resetCountdown,
		matchDuration = matchCfg.MATCH_DURATION,
		finalizing = finalizing,
		finalizeCountdown = finalizeCountdown,
		connectedPlayers = #getConnectedPlayers(),
		eligiblePlayers = #getEligiblePlayers(),
		playersPerTeam = {
			[matchCfg.TEAM_AZUL] = countTeamTotal(matchCfg.TEAM_AZUL),
			[matchCfg.TEAM_ROJO] = countTeamTotal(matchCfg.TEAM_ROJO),
		},
	}
	matchStateChanged:FireAllClients(payload)

	-- También actualizar la info por jugador (para saber su equipo).
	for player, team in pairs(playerTeam) do
		if player.Parent then
			player:SetAttribute("Team", team)
		end
	end
end

local function teleportToLobby(player)
	-- Propósito: Teletransportar al jugador de vuelta al lobby.
	-- Precondiciones:
	--   1. player tiene personaje.
	-- Ubicación: ServerScriptService/MatchService
	-- Retorna: nil
	local char = player.Character
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end

	local target = Vector3.zero
	local spawnLoc = workspace:FindFirstChild("SpawnLocation")
	if spawnLoc and spawnLoc:IsA("BasePart") then
		target = spawnLoc.Position
	else
		local piso = workspace:FindFirstChild("piso")
		if piso then
			target = piso.Position + Vector3.new(0, 5, 0)
		end
	end

	root.CFrame = CFrame.new(target)
	root.AssemblyLinearVelocity = Vector3.zero
	root.AssemblyAngularVelocity = Vector3.zero
end

local function resetMatch()
	-- Propósito: Limpiar todo el estado de la partida y volver al lobby.
	-- Precondiciones: ninguna.
	-- Ubicación: ServerScriptService/MatchService
	-- Retorna: nil
	currentState = matchCfg.STATE_LOBBY
	matchTimer = 0
	countdownTimer = 0
	resetCountdown = 0
	matchActive = false
	playerTeam = {}
	teamEliminated = {}
	finalizing = false
	finalizeCountdown = 0
	finalizeWinner = nil

	-- Resetear estados de jugadores y teleportarlos al lobby.
	if _G.ZB and _G.ZB.PlayerState then
		for _, player in ipairs(Players:GetPlayers()) do
			_G.ZB.PlayerState.reset(player)
			player:SetAttribute("Team", nil)
			setBattleParticipant(player, false)
			-- Resetear el estado físico del personaje (descongelar, desbloquear).
			if player.Character and _G.ZB.FreezeService then
				_G.ZB.FreezeService.reset(player.Character)
			end
			teleportToLobby(player)
		end
	end

	-- Volver a modo lobby.
	if _G.ZB and _G.ZB.GameMode then
		_G.ZB.GameMode.setMode(modeCfg.LOBBY)
	end

	-- Resetear el dummy NPC para la próxima partida.
	if dummyModel and dummyModel.Parent then
		if _G.ZB and _G.ZB.FreezeService then
			_G.ZB.FreezeService.reset(dummyModel)
		end
	end
	dummyModel = nil

	if canStartRound() then
		currentState = matchCfg.STATE_COUNTDOWN
		countdownTimer = matchCfg.COUNTDOWN
	else
		currentState = matchCfg.STATE_LOBBY
		countdownTimer = 0
	end
	broadcastState()
end

local function checkAnnihilation()
	-- Propósito: Detectar si un equipo fue aniquilado (el otro gana).
	-- Precondiciones: ninguna.
	-- Ubicación: ServerScriptService/MatchService
	-- Retorna: string (equipo ganador) o nil
	local azulVivos = countTeamPlayers(matchCfg.TEAM_AZUL)
	local rojoVivos = countTeamPlayers(matchCfg.TEAM_ROJO)
	local azulTotal = countTeamTotal(matchCfg.TEAM_AZUL)
	local rojoTotal = countTeamTotal(matchCfg.TEAM_ROJO)

	if azulTotal > 0 and azulVivos == 0 and rojoVivos > 0 then
		return matchCfg.TEAM_ROJO
	elseif rojoTotal > 0 and rojoVivos == 0 and azulVivos > 0 then
		return matchCfg.TEAM_AZUL
	end
	return nil
end

local function getImmediateWinner()
	local azulVivos = countTeamPlayers(matchCfg.TEAM_AZUL)
	local rojoVivos = countTeamPlayers(matchCfg.TEAM_ROJO)
	local alivePlayers = countAlivePlayers()

	if alivePlayers <= 0 then
		return nil
	end

	if azulVivos > 0 and rojoVivos == 0 then
		return matchCfg.TEAM_AZUL
	elseif rojoVivos > 0 and azulVivos == 0 then
		return matchCfg.TEAM_ROJO
	end

	return checkAnnihilation()
end

local function checkWinCondition()
	-- Propósito: Verificar si se acabó el tiempo (gana el equipo con más vivos).
	-- Precondiciones: ninguna.
	-- Ubicación: ServerScriptService/MatchService
	-- Retorna: string (equipo ganador) o nil
	local azulVivos = countTeamPlayers(matchCfg.TEAM_AZUL)
	local rojoVivos = countTeamPlayers(matchCfg.TEAM_ROJO)
	local azulTotal = countTeamTotal(matchCfg.TEAM_AZUL)
	local rojoTotal = countTeamTotal(matchCfg.TEAM_ROJO)

	if matchTimer >= matchCfg.MATCH_DURATION and azulTotal + rojoTotal > 0 then
		if azulVivos > rojoVivos then return matchCfg.TEAM_AZUL
		elseif rojoVivos > azulVivos then return matchCfg.TEAM_ROJO
		else return nil end -- empate
	end

	return nil
end

local function endMatch(winningTeam, resultMessage)
	-- Propósito: Finalizar la partida con un ganador.
	-- Precondiciones:
	--   1. winningTeam es "Azul", "Rojo" o nil (empate).
	-- Ubicación: ServerScriptService/MatchService
	-- Retorna: nil
	currentState = matchCfg.STATE_ENDING
	broadcastState()

	-- Anunciar ganador a todos los clientes.
	local result = resultMessage or winningTeam or "Empate"
	matchStateChanged:FireAllClients({
		state = currentState,
		winner = result,
		matchTimer = matchTimer,
	})

	task.wait(3)
	resetMatch()
end

local function startMatch()
	-- Propósito: Iniciar la partida con todos los jugadores conectados.
	-- Precondiciones:
	--   1. Hay suficientes jugadores conectados.
	-- Ubicación: ServerScriptService/MatchService
	-- Retorna: nil
	local participants = getEligiblePlayers()
	if #participants < matchCfg.MIN_PLAYERS_TO_START then
		currentState = matchCfg.STATE_LOBBY
		countdownTimer = 0
		broadcastState()
		return
	end

	assignTeamsForPlayers(participants)
	currentState = matchCfg.STATE_ACTIVE
	countdownTimer = 0
	matchTimer = 0
	matchActive = true

	-- Registrar el dummy NPC y asignarlo al equipo Rojo.
	dummyModel = findDummy()

	-- Cambiar a gravedad cero.
	if _G.ZB and _G.ZB.GameMode then
		_G.ZB.GameMode.setMode(modeCfg.BATTLE)
	end

	-- Teleportar jugadores a la arena.
	for player, _ in pairs(playerTeam) do
		if player.Parent then
			setBattleParticipant(player, true)
			teleportToArena(player)
		end
	end
	for _, player in ipairs(Players:GetPlayers()) do
		if not playerTeam[player] then
			setBattleParticipant(player, false)
		end
	end

	-- Notificar al RankService.
	if _G.ZB and _G.ZB.RankService then
		_G.ZB.RankService.onModeStarted(modeCfg.BATTLE)
		for _, player in ipairs(participants) do
			if player.Parent then
				_G.ZB.RankService.addMatch(player)
			end
		end
	end

	broadcastState()
end

-- ===== API pública =====
local MatchService = {}

function MatchService.getState()
	-- Propósito: Obtener el estado actual de la partida.
	-- Precondiciones: ninguna.
	-- Ubicación: ServerScriptService/MatchService
	-- Retorna: string (STATE_*)
	return currentState
end

function MatchService.getPlayerTeam(player)
	-- Propósito: Saber a qué equipo pertenece un jugador.
	-- Precondiciones:
	--   1. player es un Player válido.
	-- Ubicación: ServerScriptService/MatchService
	-- Retorna: string o nil
	return playerTeam[player]
end

function MatchService.canJoin()
	-- Propósito: Compatibilidad con el viejo portal manual.
	-- Precondiciones: ninguna.
	-- Ubicación: ServerScriptService/MatchService
	-- Retorna: boolean
	return currentState == matchCfg.STATE_LOBBY or currentState == matchCfg.STATE_COUNTDOWN
end

function MatchService.requestJoin(player)
	-- Propósito: Compatibilidad con el viejo portal manual.
	-- Precondiciones:
	--   1. player es un Player válido y conectado.
	-- Ubicación: ServerScriptService/MatchService
	-- Retorna: boolean (true si fue aceptado)
	if not player or not player.Parent then return false end
	if currentState == matchCfg.STATE_LOBBY and canStartRound() then
		startCountdown()
	end
	broadcastState()
	return MatchService.canJoin()
end

function MatchService.forceStart()
	-- Propósito: Admin fuerza el inicio de la partida ignorando el mínimo.
	-- Precondiciones:
	--   1. Estado LOBBY.
	-- Ubicación: ServerScriptService/MatchService
	-- Retorna: nil
	if currentState ~= matchCfg.STATE_LOBBY then return end
	if not canStartRound() then return end
	currentState = matchCfg.STATE_COUNTDOWN
	countdownTimer = matchCfg.COUNTDOWN
	broadcastState()
end

-- ===== Loop principal (servidor, cada segundo) =====
task.spawn(function()
	while true do
		task.wait(1)

		if currentState == matchCfg.STATE_COUNTDOWN then
			if not canStartRound() then
				currentState = matchCfg.STATE_LOBBY
				countdownTimer = 0
				broadcastState()
				continue
			end

			countdownTimer = countdownTimer - 1
			if countdownTimer <= 0 then
				startMatch()
			else
				broadcastState()
			end

		elseif currentState == matchCfg.STATE_ACTIVE or currentState == matchCfg.STATE_LOCKED then
			matchTimer = matchTimer + 1

			if countActiveParticipants() < matchCfg.MIN_PLAYERS_TO_START then
				endMatch(nil, "Partida invalida")
				continue
			end

			-- Cronómetro final (último equipo en pie).
			if finalizing then
				local currentWinner = getImmediateWinner()
				if not currentWinner then
					finalizing = false
					finalizeCountdown = 0
					finalizeWinner = nil
					broadcastState()
					continue
				end
				finalizeWinner = currentWinner
				finalizeCountdown = finalizeCountdown - 1
				if finalizeCountdown <= 0 then
					endMatch(finalizeWinner)
				else
					broadcastState()
				end
			else
				-- Cuando ya solo queda un lado con vida, iniciar el cierre.
				local winnerNow = getImmediateWinner()
				if winnerNow then
					finalizing = true
					finalizeCountdown = matchCfg.FINALIZE_TIME
					finalizeWinner = winnerNow
					broadcastState()
				else
					-- Tiempo cumplido.
					local timeout = checkWinCondition()
					if timeout then
						endMatch(timeout)
					else
						broadcastState()
					end
				end
			end

		elseif currentState == matchCfg.STATE_RESET then
			resetCountdown = resetCountdown - 1
			if resetCountdown <= 0 then
				resetMatch()
			else
				broadcastState()
			end
		end
	end
end)

-- ===== Manejo de nuevos jugadores y respawns =====
Players.PlayerAdded:Connect(function(player)
	setBattleParticipant(player, false)
	if currentState == matchCfg.STATE_LOBBY and canStartRound() then
		startCountdown()
	end
	player:SetAttribute(matchCfg.OPT_OUT_ATTRIBUTE, player:GetAttribute(matchCfg.OPT_OUT_ATTRIBUTE) == true)
	broadcastState()

	player.CharacterAdded:Connect(function(char)
		task.wait(0.3)
		if _G.ZB and _G.ZB.FreezeService then
			_G.ZB.FreezeService.reset(char)
		end
		-- Si el jugador ya está en la partida y ésta está activa,
		-- teleportarlo a su spawn de equipo (respawn).
		if playerTeam[player] and (currentState == matchCfg.STATE_ACTIVE or currentState == matchCfg.STATE_LOCKED) then
			setBattleParticipant(player, true)
			teleportToArena(player)
		else
			setBattleParticipant(player, false)
		end
	end)
end)

-- ===== RemoteEvent: jugador pide unirse vía portal =====
joinRequest.OnServerEvent:Connect(function(player)
	MatchService.requestJoin(player)
end)

-- ===== Limpieza al salir =====
Players.PlayerRemoving:Connect(function(player)
	playerTeam[player] = nil
	player:SetAttribute("Team", nil)

	if currentState == matchCfg.STATE_COUNTDOWN then
		if canStartRound() then
			broadcastState()
		else
			currentState = matchCfg.STATE_LOBBY
			countdownTimer = 0
			broadcastState()
		end
		return
	end

	-- Si era el último de su equipo y la partida está activa, verificar victoria.
	if matchActive and (currentState == matchCfg.STATE_ACTIVE or currentState == matchCfg.STATE_LOCKED) then
		if countActiveParticipants() < matchCfg.MIN_PLAYERS_TO_START then
			endMatch(nil, "Partida invalida")
			return
		end
		local winner = checkAnnihilation()
		if not winner then
			winner = getImmediateWinner()
		end
		if not winner then
			winner = checkWinCondition()
		end
		if winner then
			endMatch(winner)
		end
	end
end)

battleOptOutChanged.OnServerEvent:Connect(function(player, optedOut)
	if type(optedOut) ~= "boolean" then return end
	player:SetAttribute(matchCfg.OPT_OUT_ATTRIBUTE, optedOut)

	if currentState == matchCfg.STATE_LOBBY then
		if canStartRound() then
			startCountdown()
		end
	elseif currentState == matchCfg.STATE_COUNTDOWN and not canStartRound() then
		currentState = matchCfg.STATE_LOBBY
		countdownTimer = 0
	end

	broadcastState()
end)

-- ===== Exponer API =====
_G.ZB = _G.ZB or {}
_G.ZB.MatchService = MatchService

broadcastState()
