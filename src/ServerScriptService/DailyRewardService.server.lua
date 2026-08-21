-- Tipo: Script
-- Ubicación: ServerScriptService/DailyRewardService
-- Contexto: Servidor

local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

local REWARDS = { 50, 75, 100, 125, 150, 200, 300 }

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

local claimDailyReward = ensureRemote('ClaimDailyReward')
local dailyRewardState = ensureRemote('DailyRewardState')

local function getUtcDayNow()
	return math.floor(os.time() / 86400)
end

local function waitForDataService(timeout)
	local started = os.clock()
	while os.clock() - started < (timeout or 15) do
		local service = _G.ZB and _G.ZB.DataService
		if service then
			return service
		end
		task.wait(0.1)
	end
	return _G.ZB and _G.ZB.DataService
end

local function buildState(profile)
	local today = getUtcDayNow()
	local lastClaimDay = profile.daily.lastClaimDay or 0
	local streak = math.max(0, profile.daily.streak or 0)
	local claimedToday = lastClaimDay == today
	local nextStreak = 1
	if claimedToday then
		nextStreak = math.max(1, math.min(streak, #REWARDS))
	elseif lastClaimDay == (today - 1) then
		nextStreak = math.min(streak + 1, #REWARDS)
	end
	local reward = REWARDS[nextStreak]
	return {
		available = not claimedToday,
		claimedToday = claimedToday,
		streak = streak,
		nextStreak = nextStreak,
		reward = reward,
		maxStreak = #REWARDS,
	}
end

local function pushState(player, message)
	local dataService = waitForDataService()
	if not dataService or not dataService.isLoaded(player) then return end
	local profile = dataService.getProfile(player)
	if not profile then return end
	local state = buildState(profile)
	state.message = message
	dailyRewardState:FireClient(player, state)
end

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

claimDailyReward.OnServerEvent:Connect(function(player)
	local dataService = waitForDataService()
	if not dataService or not dataService.isLoaded(player) then return end
	local profile = dataService.getProfile(player)
	if not profile then return end
	local state = buildState(profile)
	if not state.available then
		pushState(player, 'Recompensa ya reclamada hoy')
		return
	end
	local today = getUtcDayNow()
	local reward = state.reward
	dataService.updateProfile(player, function(nextProfile)
		nextProfile.daily.lastClaimDay = today
		nextProfile.daily.streak = state.nextStreak
		nextProfile.coins = math.max(0, math.floor(tonumber(nextProfile.coins) or 0)) + reward
	end)
	local missionService = _G.ZB and _G.ZB.MissionService
	if missionService then
		missionService.recordProgress(player, 'dailyClaims', 1)
	end
	dataService.save(player)
	pushState(player, 'Recompensa diaria: +' .. tostring(reward) .. ' monedas')
end)
