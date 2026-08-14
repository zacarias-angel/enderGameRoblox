-- Tipo: Script
-- Ubicación: ServerScriptService/MatchService
-- Contexto: Servidor

--[[
	MatchService
	Sistema completo de partidas con portal, equipos balanceados y timer.
	Flujo de una partida:

	  LOBBY → COUNTDOWN → ACTIVE → LOCKED → ENDING → RESET → LOBBY ...

	- LOBBY: jugadores en el lobby, portal abierto (verde).
	         Se forma cola. Al llegar al mínimo o por comando admin, arranca
	         la cuenta regresiva.
	- COUNTDOWN: 10s de cuenta regresiva. Se asignan equipos balanceados.
	             El portal sigue aceptando jugadores (verde).
	- ACTIVE: partida en curso. Jugadores teleportados a spawns. Gravedad 0.
	          JOIN_WINDOW (60s): el portal sigue abierto (amarillo), nuevos
	          jugadores pueden entrar al equipo con menos jugadores.
	- LOCKED: JOIN_WINDOW terminó. Portal cerrado (rojo). No entran más
	          jugadores. La partida sigue hasta que un equipo elimine al otro
	          o se acabe MATCH_DURATION (gana el equipo con más vivos).
	- ENDING: se anuncia el ganador. 3s de pausa.
	- RESET: se devuelve a todos al lobby, gravedad normal. Se limpia el
	         estado. Luego vuelve a LOBBY.

	RemoteEvents: JoinMatchRequest (cliente→servidor), MatchStateChanged (s→c).
	API: _G.ZB.MatchService.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local matchCfg = Config.Match
local portalCfg = Config.Portal
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
local modeChanged = ensureRemote("GameModeChanged")

-- ===== Estado global =====
local currentState = matchCfg.STATE_LOBBY
local playerTeam = {}      -- [player] = "Azul" | "Rojo"
local queue = {}           -- { player } jugadores que pidieron entrar (antes de arrancar)
local matchTimer = 0       -- tiempo transcurrido desde ACTIVE
local joinWindowTimer = 0  -- tiempo restante de ventana de entrada
local countdownTimer = 0   -- tiempo restante de cuenta regresiva
local matchActive = false
local teamEliminated = {}  -- [team] = true si el equipo fue aniquilado

local function countTeamPlayers(team)
	-- Propósito: Contar jugadores vivos en un equipo.
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
	return count
end

local function countTeamTotal(team)
	-- Propósito: Contar jugadores totales (vivos o no) en un equipo.
	-- Precondiciones:
	--   1. team es "Azul" o "Rojo".
	-- Ubicación: ServerScriptService/MatchService
	-- Retorna: number
	local count = 0
	for _, t in pairs(playerTeam) do
		if t == team then count = count + 1 end
	end
	return count
end

local function assignTeam(player)
	-- Propósito: Asignar al jugador al equipo con menos jugadores.
	-- Precondiciones:
	--   1. player es un Player válido.
	-- Ubicación: ServerScriptService/MatchService
	-- Retorna: string ("Azul" o "Rojo")
	local azul = countTeamTotal(matchCfg.TEAM_AZUL)
	local rojo = countTeamTotal(matchCfg.TEAM_ROJO)
	if azul <= rojo then
		playerTeam[player] = matchCfg.TEAM_AZUL
		return matchCfg.TEAM_AZUL
	else
		playerTeam[player] = matchCfg.TEAM_ROJO
		return matchCfg.TEAM_ROJO
	end
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

local function broadcastState()
	-- Propósito: Enviar el estado actual de la partida a todos los clientes.
	-- Precondiciones: ninguna.
	-- Ubicación: ServerScriptService/MatchService
	-- Retorna: nil
	local payload = {
		state = currentState,
		matchTimer = matchTimer,
		joinWindow = joinWindowTimer,
		countdown = countdownTimer,
		matchDuration = matchCfg.MATCH_DURATION,
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

local function resetMatch()
	-- Propósito: Limpiar todo el estado de la partida y volver al lobby.
	-- Precondiciones: ninguna.
	-- Ubicación: ServerScriptService/MatchService
	-- Retorna: nil
	currentState = matchCfg.STATE_LOBBY
	matchTimer = 0
	joinWindowTimer = 0
	countdownTimer = 0
	matchActive = false
	queue = {}
	playerTeam = {}
	teamEliminated = {}

	-- Resetear estados de jugadores.
	if _G.ZB and _G.ZB.PlayerState then
		for _, player in ipairs(Players:GetPlayers()) do
			_G.ZB.PlayerState.reset(player)
			player:SetAttribute("Team", nil)
		end
	end

	-- Volver a modo lobby.
	if _G.ZB and _G.ZB.GameMode then
		_G.ZB.GameMode.setMode(modeCfg.LOBBY)
	end

	broadcastState()
end

local function checkWinCondition()
	-- Propósito: Verificar si un equipo fue aniquilado o se acabó el tiempo.
	-- Precondiciones: ninguna.
	-- Ubicación: ServerScriptService/MatchService
	-- Retorna: string (equipo ganador) o nil
	local azulVivos = countTeamPlayers(matchCfg.TEAM_AZUL)
	local rojoVivos = countTeamPlayers(matchCfg.TEAM_ROJO)
	local azulTotal = countTeamTotal(matchCfg.TEAM_AZUL)
	local rojoTotal = countTeamTotal(matchCfg.TEAM_ROJO)

	if matchTimer >= matchCfg.MATCH_DURATION and azulTotal + rojoTotal > 0 then
		-- Tiempo cumplido: gana el equipo con más vivos.
		if azulVivos > rojoVivos then return matchCfg.TEAM_AZUL
		elseif rojoVivos > azulVivos then return matchCfg.TEAM_ROJO
		else return nil end -- empate
	end

	-- Aniquilación: un equipo no tiene jugadores vivos y el otro sí.
	if azulTotal > 0 and azulVivos == 0 and rojoVivos > 0 then
		return matchCfg.TEAM_ROJO
	elseif rojoTotal > 0 and rojoVivos == 0 and azulVivos > 0 then
		return matchCfg.TEAM_AZUL
	end

	return nil
end

local function endMatch(winningTeam)
	-- Propósito: Finalizar la partida con un ganador.
	-- Precondiciones:
	--   1. winningTeam es "Azul", "Rojo" o nil (empate).
	-- Ubicación: ServerScriptService/MatchService
	-- Retorna: nil
	currentState = matchCfg.STATE_ENDING
	broadcastState()

	-- Anunciar ganador a todos los clientes.
	local result = winningTeam or "Empate"
	matchStateChanged:FireAllClients({
		state = currentState,
		winner = result,
		matchTimer = matchTimer,
	})

	task.wait(3)

	currentState = matchCfg.STATE_RESET
	broadcastState()

	task.wait(matchCfg.RESET_TIME)
	resetMatch()
end

local function startMatch()
	-- Propósito: Iniciar la partida: asignar equipos, teleportar, cambiar modo.
	-- Precondiciones:
	--   1. Hay al menos 1 jugador en cola.
	-- Ubicación: ServerScriptService/MatchService
	-- Retorna: nil
	currentState = matchCfg.STATE_COUNTDOWN
	countdownTimer = matchCfg.COUNTDOWN
	matchActive = true
	broadcastState()

	-- Asignar equipos a todos los jugadores en cola.
	for _, player in ipairs(queue) do
		if player.Parent then
			assignTeam(player)
		end
	end

	-- También asignar a cualquier jugador que ya tenga equipo (por reentrada).
	for _, player in ipairs(Players:GetPlayers()) do
		if not playerTeam[player] then
			-- No está en la partida, puede ser espectador
		end
	end

	-- Cambiar a gravedad cero.
	if _G.ZB and _G.ZB.GameMode then
		_G.ZB.GameMode.setMode(modeCfg.BATTLE)
	end

	-- Teleportar jugadores a la arena.
	for player, _ in pairs(playerTeam) do
		if player.Parent then
			teleportToArena(player)
		end
	end

	-- Notificar al RankService.
	if _G.ZB and _G.ZB.RankService then
		_G.ZB.RankService.onModeStarted(modeCfg.BATTLE)
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
	-- Propósito: Saber si un jugador nuevo puede entrar a la partida.
	-- Precondiciones: ninguna.
	-- Ubicación: ServerScriptService/MatchService
	-- Retorna: boolean
	return currentState == matchCfg.STATE_LOBBY
		or currentState == matchCfg.STATE_COUNTDOWN
		or currentState == matchCfg.STATE_ACTIVE
end

function MatchService.requestJoin(player)
	-- Propósito: Un jugador pide entrar a la partida vía portal.
	-- Precondiciones:
	--   1. player es un Player válido y conectado.
	-- Ubicación: ServerScriptService/MatchService
	-- Retorna: boolean (true si fue aceptado)
	if not player or not player.Parent then return false end

	-- Ya está en la partida.
	if playerTeam[player] then
		return true
	end

	if not MatchService.canJoin() then
		return false
	end

	-- En LOBBY: añadir a la cola.
	if currentState == matchCfg.STATE_LOBBY then
		table.insert(queue, player)
		-- Asignar equipo temporal (se reasignará al arrancar la partida
		-- para balancear con TODOS los de la cola).
		assignTeam(player)

		-- Si hay suficientes jugadores, iniciar cuenta regresiva.
		if #queue >= matchCfg.MIN_PLAYERS_TO_START then
			startMatch()
		end
		broadcastState()
		return true
	end

	-- En COUNTDOWN: añadir a la cola y rebalancear.
	if currentState == matchCfg.STATE_COUNTDOWN then
		table.insert(queue, player)
		assignTeam(player)

		-- Notificar a este jugador que está en modo BATTLE (ya empezó).
		modeChanged:FireClient(player, modeCfg.BATTLE, modeCfg.LOBBY)

		broadcastState()
		return true
	end

	-- En ACTIVE (ventana abierta): entrar directo, sin cola.
	if currentState == matchCfg.STATE_ACTIVE then
		assignTeam(player)
		teleportToArena(player)

		-- Notificar al cliente que está en modo BATTLE para que active
		-- físicas 0g, pose de nado, etc. (GameModeChanged global ya pasó).
		modeChanged:FireClient(player, modeCfg.BATTLE, modeCfg.LOBBY)

		broadcastState()
		return true
	end

	return false
end

function MatchService.forceStart()
	-- Propósito: Admin fuerza el inicio de la partida ignorando el mínimo.
	-- Precondiciones:
	--   1. Estado LOBBY.
	-- Ubicación: ServerScriptService/MatchService
	-- Retorna: nil
	if currentState ~= matchCfg.STATE_LOBBY then return end
	-- Meter a todos los jugadores presentes en la cola.
	for _, player in ipairs(Players:GetPlayers()) do
		if not playerTeam[player] then
			table.insert(queue, player)
		end
	end
	if #queue > 0 then
		startMatch()
	end
end

-- ===== Loop principal (servidor, cada segundo) =====
task.spawn(function()
	while true do
		task.wait(1)

		if currentState == matchCfg.STATE_COUNTDOWN then
			countdownTimer = countdownTimer - 1
			if countdownTimer <= 0 then
				-- Rebalancear equipos con todos los de la cola.
				local oldTeams = {}
				for player, team in pairs(playerTeam) do
					oldTeams[player] = team
				end
				playerTeam = {}
				for _, player in ipairs(queue) do
					if player.Parent then
						assignTeam(player)
					end
				end
				queue = {}

			currentState = matchCfg.STATE_ACTIVE
			joinWindowTimer = matchCfg.JOIN_WINDOW
			matchTimer = 0

			-- Registrar partida jugada en el ranking.
			if _G.ZB and _G.ZB.RankService then
				for player, _ in pairs(playerTeam) do
					if player.Parent then
						_G.ZB.RankService.addMatch(player)
					end
				end
			end

			-- Teleportar a los que cambiaron de equipo o son nuevos.
				for player, _ in pairs(playerTeam) do
					if player.Parent then
						teleportToArena(player)
					end
				end
				broadcastState()
			else
				broadcastState()
			end

		elseif currentState == matchCfg.STATE_ACTIVE then
			matchTimer = matchTimer + 1
			joinWindowTimer = math.max(0, joinWindowTimer - 1)

			if joinWindowTimer <= 0 then
				-- Cerrar ventana de entrada.
				currentState = matchCfg.STATE_LOCKED
				broadcastState()
			else
				-- Verificar condición de victoria.
				local winner = checkWinCondition()
				if winner then
					endMatch(winner)
				else
					broadcastState()
				end
			end

		elseif currentState == matchCfg.STATE_LOCKED then
			matchTimer = matchTimer + 1
			local winner = checkWinCondition()
			if winner then
				endMatch(winner)
			else
				broadcastState()
			end

		end
	end
end)

-- ===== Manejo de nuevos jugadores y respawns =====
Players.PlayerAdded:Connect(function(player)
	-- Si el jugador se une durante una partida activa, asegurar que spawnee
	-- en el lobby (no en la arena). El SpawnLocation del lobby debe existir.
	-- No lo metemos a la partida automáticamente: debe usar el portal.
	player.CharacterAdded:Connect(function(char)
		task.wait(0.3)
		-- Si el jugador ya está en la partida y ésta está activa,
		-- teleportarlo a su spawn de equipo (respawn).
		if playerTeam[player] and (currentState == matchCfg.STATE_ACTIVE or currentState == matchCfg.STATE_LOCKED) then
			teleportToArena(player)
		end
	end)
end)

-- ===== RemoteEvent: jugador pide unirse vía portal =====
joinRequest.OnServerEvent:Connect(function(player)
	MatchService.requestJoin(player)
end)

-- ===== Limpieza al salir =====
Players.PlayerRemoving:Connect(function(player)
	-- Eliminar de cola.
	for i, p in ipairs(queue) do
		if p == player then
			table.remove(queue, i)
			break
		end
	end
	playerTeam[player] = nil

	-- Si era el último de su equipo y la partida está activa, verificar victoria.
	if matchActive and (currentState == matchCfg.STATE_ACTIVE or currentState == matchCfg.STATE_LOCKED) then
		local winner = checkWinCondition()
		if winner then
			endMatch(winner)
		end
	end
end)

-- ===== Exponer API =====
_G.ZB = _G.ZB or {}
_G.ZB.MatchService = MatchService
