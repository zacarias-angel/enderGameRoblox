-- Tipo: Script
-- Ubicación: ServerScriptService/MatchService
-- Contexto: Servidor

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local matchCfg = Config.Match
local modeCfg = Config.GameMode

local function ensureRemote(name)
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

local currentState = matchCfg.STATE_LOBBY
local playerTeam = {}
local matchTimer = 0
local countdownTimer = 0
local finalizing = false
local finalizeCountdown = 0
local finalizeWinner = nil
local dummyModel = nil
local dummyTeam = matchCfg.TEAM_ROJO
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
	local list = {}
	for _, player in ipairs(Players:GetPlayers()) do
		if player.Parent then
			table.insert(list, player)
		end
	end
	table.sort(list, function(a, b)
		return a.UserId < b.UserId
	end)
	return list
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

local function getRequiredPlayersToStart()
	return matchCfg.MIN_PLAYERS_TO_START
end

local function getCountdownDuration()
	return matchCfg.COUNTDOWN
end

local function canStartRound()
	return #getEligiblePlayers() >= getRequiredPlayersToStart()
end

local function countActiveParticipants()
	local count = 0
	for player in pairs(playerTeam) do
		if player.Parent then
			count += 1
		end
	end
	return count
end

local function findDummy()
	for _, inst in ipairs(workspace:GetDescendants()) do
		if inst:IsA("Humanoid") and inst.Parent and inst.Parent:IsA("Model") then
			local model = inst.Parent
			if not Players:GetPlayerFromCharacter(model) and model:GetAttribute("IsMatchDummy") == true then
				return model
			end
		end
	end
	return nil
end

local function isDummyAlive()
	return dummyModel and dummyModel.Parent and dummyModel:GetAttribute("cubrirce") ~= true
end

local function countTeamPlayers(team)
	local count = 0
	local PlayerState = _G.ZB and _G.ZB.PlayerState
	for player, assignedTeam in pairs(playerTeam) do
		if assignedTeam == team and player.Parent and PlayerState and PlayerState.isAlive(player) then
			count += 1
		end
	end
	if dummyTeam == team and isDummyAlive() then
		count += 1
	end
	return count
end

local function countAlivePlayers()
	local alive = 0
	for player in pairs(playerTeam) do
		if player.Parent then
			local PlayerState = _G.ZB and _G.ZB.PlayerState
			if PlayerState and PlayerState.isAlive(player) then
				alive += 1
			end
		end
	end
	if dummyModel and dummyModel.Parent and dummyModel:GetAttribute("cubrirce") ~= true then
		alive += 1
	end
	return alive
end

local function countTeamTotal(team)
	local count = 0
	for _, assignedTeam in pairs(playerTeam) do
		if assignedTeam == team then
			count += 1
		end
	end
	if dummyTeam == team and dummyModel then
		count += 1
	end
	return count
end

local function broadcastState(extra)
	extra = extra or {}
	local payload = {
		state = currentState,
		countdown = countdownTimer,
		matchTimer = matchTimer,
		matchDuration = matchCfg.MATCH_DURATION,
		finalizing = finalizing,
		finalizeCountdown = finalizeCountdown,
		connectedPlayers = #getConnectedPlayers(),
		eligiblePlayers = #getEligiblePlayers(),
		requiredPlayers = getRequiredPlayersToStart(),
		playersPerTeam = {
			[matchCfg.TEAM_AZUL] = countTeamTotal(matchCfg.TEAM_AZUL),
			[matchCfg.TEAM_ROJO] = countTeamTotal(matchCfg.TEAM_ROJO),
		},
	}
	for k, v in pairs(extra) do
		payload[k] = v
	end
	matchStateChanged:FireAllClients(payload)
	for player, team in pairs(playerTeam) do
		if player.Parent then
			player:SetAttribute("Team", team)
		end
	end
end

local function getSpawnPosition(player)
	local team = playerTeam[player]
	if not team then return Vector3.zero end
	local arena = workspace:FindFirstChild("Arena")
	local spawnName = team == matchCfg.TEAM_AZUL and matchCfg.SPAWN_AZUL_NAME or matchCfg.SPAWN_ROJO_NAME
	if arena then
		local spawnPart = arena:FindFirstChild(spawnName)
		if spawnPart and spawnPart:IsA("BasePart") then
			return spawnPart.Position
		end
		local teamFolder = arena:FindFirstChild(team)
		if teamFolder then
			local sp = teamFolder:FindFirstChild("Spawn")
			if sp and sp:IsA("BasePart") then
				return sp.Position
			end
		end
	end
	local portal = workspace:FindFirstChild("Portal")
	local origin = portal and portal:IsA("BasePart") and portal.Position or Vector3.zero
	return origin + (team == matchCfg.TEAM_AZUL and matchCfg.ARENA_SPAWN_BLUE_OFFSET or matchCfg.ARENA_SPAWN_RED_OFFSET)
end

local function teleportToArena(player)
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root then return end
	root.CFrame = CFrame.new(getSpawnPosition(player))
	root.AssemblyLinearVelocity = Vector3.zero
	root.AssemblyAngularVelocity = Vector3.zero
end

local function teleportToLobby(player)
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root then return end
	local spawnLoc = workspace:FindFirstChild("SpawnLocation")
	local piso = workspace:FindFirstChild("piso")
	local target = spawnLoc and spawnLoc.Position or (piso and (piso.Position + Vector3.new(0, 5, 0)) or Vector3.zero)
	root.CFrame = CFrame.new(target)
	root.AssemblyLinearVelocity = Vector3.zero
	root.AssemblyAngularVelocity = Vector3.zero
end

local function assignTeams(players)
	table.clear(playerTeam)
	for index, player in ipairs(players) do
		playerTeam[player] = (index % 2 == 1) and matchCfg.TEAM_AZUL or matchCfg.TEAM_ROJO
	end
end

local function resetMatch()
	currentState = canStartRound() and matchCfg.STATE_COUNTDOWN or matchCfg.STATE_LOBBY
	countdownTimer = canStartRound() and getCountdownDuration() or 0
	matchTimer = 0
	finalizing = false
	finalizeCountdown = 0
	finalizeWinner = nil
	table.clear(playerTeam)
	if _G.ZB and _G.ZB.PlayerState then
		for _, player in ipairs(Players:GetPlayers()) do
			_G.ZB.PlayerState.reset(player)
			player:SetAttribute("Team", nil)
			setBattleParticipant(player, false)
			if player.Character and _G.ZB.FreezeService then
				_G.ZB.FreezeService.reset(player.Character)
			end
			teleportToLobby(player)
		end
	end
	if _G.ZB and _G.ZB.GameMode then
		_G.ZB.GameMode.setMode(modeCfg.LOBBY)
	end
	if dummyModel and dummyModel.Parent and _G.ZB and _G.ZB.FreezeService then
		_G.ZB.FreezeService.reset(dummyModel)
	end
	dummyModel = nil
	broadcastState()
end

local function endMatch(winner, message)
	currentState = matchCfg.STATE_ENDING
	broadcastState({ winner = message or winner or "Empate" })
	task.wait(3)
	resetMatch()
end

local function checkAnnihilation()
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
	if alivePlayers <= 0 then return nil end
	if azulVivos > 0 and rojoVivos == 0 then return matchCfg.TEAM_AZUL end
	if rojoVivos > 0 and azulVivos == 0 then return matchCfg.TEAM_ROJO end
	return checkAnnihilation()
end

local function checkTimeoutWinner()
	if matchTimer < matchCfg.MATCH_DURATION then return nil end
	local azulVivos = countTeamPlayers(matchCfg.TEAM_AZUL)
	local rojoVivos = countTeamPlayers(matchCfg.TEAM_ROJO)
	if azulVivos > rojoVivos then return matchCfg.TEAM_AZUL end
	if rojoVivos > azulVivos then return matchCfg.TEAM_ROJO end
	return nil
end

local function startMatch()
	local participants = getEligiblePlayers()
	if #participants < getRequiredPlayersToStart() then
		currentState = matchCfg.STATE_LOBBY
		countdownTimer = 0
		broadcastState()
		return
	end
	assignTeams(participants)
	dummyModel = findDummy()
	currentState = matchCfg.STATE_ACTIVE
	countdownTimer = 0
	matchTimer = 0
	finalizing = false
	finalizeCountdown = 0
	finalizeWinner = nil
	if _G.ZB and _G.ZB.GameMode then
		_G.ZB.GameMode.setMode(modeCfg.BATTLE)
	end
	for player in pairs(playerTeam) do
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
	if _G.ZB and _G.ZB.RankService then
		_G.ZB.RankService.onModeStarted(modeCfg.BATTLE)
		for _, player in ipairs(participants) do
			if player.Parent then
				_G.ZB.RankService.addMatch(player)
				local missionService = _G.ZB and _G.ZB.MissionService
				if missionService then
					missionService.recordProgress(player, "playMatches", 1)
				end
			end
		end
	end
	broadcastState()
end

local MatchService = {}
function MatchService.getState() return currentState end
function MatchService.getPlayerTeam(player) return playerTeam[player] end
function MatchService.canJoin() return currentState == matchCfg.STATE_LOBBY or currentState == matchCfg.STATE_COUNTDOWN end
function MatchService.requestJoin(player)
	if player and player.Parent and currentState == matchCfg.STATE_LOBBY and canStartRound() then
		currentState = matchCfg.STATE_COUNTDOWN
		countdownTimer = getCountdownDuration()
	end
	broadcastState()
	return MatchService.canJoin()
end
function MatchService.forceStart()
	if currentState == matchCfg.STATE_LOBBY and canStartRound() then
		currentState = matchCfg.STATE_COUNTDOWN
		countdownTimer = getCountdownDuration()
		broadcastState()
	end
end

joinRequest.OnServerEvent:Connect(function(player)
	MatchService.requestJoin(player)
end)

battleOptOutChanged.OnServerEvent:Connect(function(player, optedOut)
	if type(optedOut) ~= "boolean" then return end
	player:SetAttribute(matchCfg.OPT_OUT_ATTRIBUTE, optedOut)
	if currentState == matchCfg.STATE_LOBBY and canStartRound() then
		currentState = matchCfg.STATE_COUNTDOWN
		countdownTimer = getCountdownDuration()
	elseif currentState == matchCfg.STATE_COUNTDOWN and not canStartRound() then
		currentState = matchCfg.STATE_LOBBY
		countdownTimer = 0
	end
	broadcastState()
end)

Players.PlayerAdded:Connect(function(player)
	setBattleParticipant(player, false)
	player:SetAttribute(matchCfg.OPT_OUT_ATTRIBUTE, player:GetAttribute(matchCfg.OPT_OUT_ATTRIBUTE) == true)
	if currentState == matchCfg.STATE_LOBBY and canStartRound() then
		currentState = matchCfg.STATE_COUNTDOWN
		countdownTimer = getCountdownDuration()
	end
	broadcastState()
	player.CharacterAdded:Connect(function(char)
		task.wait(0.3)
		if _G.ZB and _G.ZB.FreezeService then
			_G.ZB.FreezeService.reset(char)
		end
		if playerTeam[player] and currentState == matchCfg.STATE_ACTIVE then
			setBattleParticipant(player, true)
			teleportToArena(player)
		else
			setBattleParticipant(player, false)
		end
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	playerTeam[player] = nil
	if currentState == matchCfg.STATE_COUNTDOWN and not canStartRound() then
		currentState = matchCfg.STATE_LOBBY
		countdownTimer = 0
		broadcastState()
		return
	end
	if currentState == matchCfg.STATE_ACTIVE and countActiveParticipants() < getRequiredPlayersToStart() then
		endMatch(nil, "Partida invalida")
	end
end)

_G.ZB = _G.ZB or {}
_G.ZB.MatchService = MatchService

broadcastState()

task.spawn(function()
	while true do
		task.wait(1)
		if currentState == matchCfg.STATE_COUNTDOWN then
			if not canStartRound() then
				currentState = matchCfg.STATE_LOBBY
				countdownTimer = 0
				broadcastState()
			elseif countdownTimer <= 1 then
				startMatch()
			else
				countdownTimer -= 1
				broadcastState()
			end
		elseif currentState == matchCfg.STATE_ACTIVE then
			matchTimer += 1
			if countActiveParticipants() < getRequiredPlayersToStart() then
				endMatch(nil, "Partida invalida")
			elseif finalizing then
				local currentWinner = getImmediateWinner()
				if not currentWinner then
					finalizing = false
					finalizeCountdown = 0
					finalizeWinner = nil
					broadcastState()
				elseif finalizeCountdown <= 1 then
					endMatch(currentWinner)
				else
					finalizeWinner = currentWinner
					finalizeCountdown -= 1
					broadcastState()
				end
			else
				local winner = getImmediateWinner()
				if winner then
					finalizing = true
					finalizeWinner = winner
					finalizeCountdown = matchCfg.FINALIZE_TIME
					broadcastState()
				else
					local timeoutWinner = checkTimeoutWinner()
					if matchTimer >= matchCfg.MATCH_DURATION then
						endMatch(timeoutWinner, timeoutWinner and nil or "Empate")
					else
						broadcastState()
					end
				end
			end
		end
	end
end)
