-- Tipo: Script
-- Ubicación: ServerScriptService/MissionService
-- Contexto: Servidor

local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

local MISSIONS = {
	{ id = 'play_match', key = 'playMatches', title = 'Jugar 1 partida', target = 1, reward = 60 },
	{ id = 'collect_coins', key = 'coinsCollected', title = 'Recolectar 25 monedas', target = 25, reward = 80 },
	{ id = 'claim_daily', key = 'dailyClaims', title = 'Reclamar recompensa diaria', target = 1, reward = 40 },
}

local function ensureRemote(name)
	local folder = ReplicatedStorage:FindFirstChild('RemoteEvents')
	if not folder then
		folder = Instance.new('Folder')
		folder.Name = 'RemoteEvents'
		folder.Parent = ReplicatedStorage
	end
	local remote = folder:FindFirstChild(name)
	if not remote then
		remote = Instance.new('RemoteEvent')
		remote.Name = name
		remote.Parent = folder
	end
	return remote
end

local missionState = ensureRemote('MissionState')
local claimMissionReward = ensureRemote('ClaimMissionReward')

local function getUtcDayNow()
	return math.floor(os.time() / 86400)
end

local function waitForDataService(timeout)
	local started = os.clock()
	while os.clock() - started < (timeout or 15) do
		local service = _G.ZB and _G.ZB.DataService
		if service then return service end
		task.wait(0.1)
	end
	return _G.ZB and _G.ZB.DataService
end

local function buildFreshEntries()
	local entries = {}
	for _, mission in ipairs(MISSIONS) do
		entries[mission.id] = {
			id = mission.id,
			key = mission.key,
			title = mission.title,
			target = mission.target,
			reward = mission.reward,
			progress = 0,
			claimed = false,
		}
	end
	return entries
end

local function normalizeEntries(entries)
	local normalized = buildFreshEntries()
	if type(entries) ~= 'table' then
		return normalized
	end
	for _, mission in ipairs(MISSIONS) do
		local current = entries[mission.id]
		if type(current) == 'table' then
			normalized[mission.id].progress = math.max(0, math.floor(tonumber(current.progress) or 0))
			normalized[mission.id].claimed = current.claimed == true
		end
	end
	return normalized
end

local function ensureMissionProfile(player)
	local dataService = waitForDataService()
	if not dataService or not dataService.isLoaded(player) then return nil end
	local today = getUtcDayNow()
	return dataService.updateProfile(player, function(profile)
		profile.missions = profile.missions or {}
		if profile.missions.lastRefreshDay ~= today then
			profile.missions.lastRefreshDay = today
			profile.missions.entries = buildFreshEntries()
		else
			profile.missions.entries = normalizeEntries(profile.missions.entries)
		end
	end)
end

local function entriesArray(profile)
	local result = {}
	for _, mission in ipairs(MISSIONS) do
		local entry = profile.missions.entries[mission.id]
		table.insert(result, {
			id = entry.id,
			title = entry.title,
			progress = entry.progress,
			target = entry.target,
			reward = entry.reward,
			claimed = entry.claimed,
			complete = entry.progress >= entry.target,
		})
	end
	return result
end

local function pushState(player, message)
	local profile = ensureMissionProfile(player)
	if not profile then return end
	missionState:FireClient(player, {
		entries = entriesArray(profile),
		message = message,
	})
end

local MissionService = {}

function MissionService.recordProgress(player, key, amount)
	local profile = ensureMissionProfile(player)
	if not profile then return end
	local safeAmount = math.max(0, math.floor(tonumber(amount) or 0))
	if safeAmount <= 0 then return end
	local updated = waitForDataService().updateProfile(player, function(nextProfile)
		local entries = normalizeEntries(nextProfile.missions.entries)
		nextProfile.missions.entries = entries
		for _, mission in ipairs(MISSIONS) do
			if mission.key == key then
				local entry = entries[mission.id]
				entry.progress = math.min(entry.target, entry.progress + safeAmount)
			end
		end
	end)
	if updated then
		pushState(player)
	end
end

function MissionService.getState(player)
	local profile = ensureMissionProfile(player)
	if not profile then return nil end
	return { entries = entriesArray(profile) }
end

claimMissionReward.OnServerEvent:Connect(function(player, missionId)
	if type(missionId) ~= 'string' then return end
	local dataService = waitForDataService()
	if not dataService or not dataService.isLoaded(player) then return end
	local profile = ensureMissionProfile(player)
	if not profile then return end
	local entry = profile.missions.entries and profile.missions.entries[missionId]
	if type(entry) ~= 'table' then return end
	if entry.claimed or entry.progress < entry.target then
		pushState(player, 'Mision no disponible')
		return
	end
	dataService.updateProfile(player, function(nextProfile)
		local currentEntry = nextProfile.missions.entries[missionId]
		if currentEntry then
			currentEntry.claimed = true
			nextProfile.coins = math.max(0, math.floor(tonumber(nextProfile.coins) or 0)) + (currentEntry.reward or 0)
		end
	end)
	dataService.save(player)
	pushState(player, 'Mision completada: +' .. tostring(entry.reward) .. ' monedas')
end)

Players.PlayerAdded:Connect(function(player)
	task.spawn(function()
		local dataService = waitForDataService()
		if not dataService then return end
		local started = os.clock()
		while not dataService.isLoaded(player) and player.Parent and os.clock() - started < 20 do
			task.wait(0.2)
		end
		if player.Parent then
			pushState(player)
		end
	end)
end)

for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(function()
		local dataService = waitForDataService()
		if not dataService then return end
		local started = os.clock()
		while not dataService.isLoaded(player) and player.Parent and os.clock() - started < 20 do
			task.wait(0.2)
		end
		if player.Parent then
			pushState(player)
		end
	end)
end

_G.ZB = _G.ZB or {}
_G.ZB.MissionService = MissionService
