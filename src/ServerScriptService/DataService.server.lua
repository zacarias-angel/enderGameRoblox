-- Tipo: Script
-- Ubicación: ServerScriptService/DataService
-- Contexto: Servidor

local Players = game:GetService('Players')
local DataStoreService = game:GetService('DataStoreService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService('RunService')

local Config = require(ReplicatedStorage:WaitForChild('Shared'):WaitForChild('Config'))
local matchCfg = Config.Match
local currencyCfg = Config.Currency
local energyCfg = Config.Energy

local STORE_NAME = 'ZeroBreach_PlayerData_v1'
local AUTOSAVE_INTERVAL = 60
local STUDIO_BYPASS_DATASTORE = RunService:IsStudio()
local dataStore = DataStoreService:GetDataStore(STORE_NAME)

local DEFAULT_PROFILE = {
	coins = currencyCfg.STARTING_COINS,
	workshop = {
		ownedWeapons = { 'blaster' },
		ownedColors = { 'cyan' },
		equippedWeaponId = 'blaster',
		equippedLaserColorId = 'cyan',
		ownedHookTips = { 'default' },
		ownedHookRopes = { 'default' },
		equippedHookTipId = 'default',
		equippedHookRopeId = 'default',
	},
	maxStamina = energyCfg.MAX,
	hookEnergy = {
		maxHookEnergy = Config.HookEnergy.MAX,
		hookRegenPerSec = Config.HookEnergy.REGEN_PER_SEC,
	},
	preferences = {
		battleOptOut = false,
	},
	stats = {
		eliminations = 0,
		limbsFrozen = 0,
		matchesPlayed = 0,
	},
	daily = {
		lastClaimDay = 0,
		streak = 0,
	},
	missions = {
		lastRefreshDay = 0,
		entries = {},
	},
	hook = {
		tipCosmeticId = 'default',
		ropeCosmeticId = 'default',
	},
}

local loadedProfiles = {}
local loadedFlags = {}

local function clone(value)
	if type(value) ~= 'table' then return value end
	local copy = {}
	for key, inner in pairs(value) do
		copy[key] = clone(inner)
	end
	return copy
end

local function normalizeStringArray(list, fallback)
	local result = {}
	local seen = {}
	if type(list) == 'table' then
		for _, value in ipairs(list) do
			if type(value) == 'string' and not seen[value] then
				seen[value] = true
				table.insert(result, value)
			end
		end
	end
	if #result == 0 then
		return clone(fallback)
	end
	return result
end

local function normalizeProfile(raw)
	local profile = clone(DEFAULT_PROFILE)
	if type(raw) ~= 'table' then
		return profile
	end

	profile.coins = math.max(0, math.floor(tonumber(raw.coins) or profile.coins))
	profile.maxStamina = math.clamp(math.floor(tonumber(raw.maxStamina) or profile.maxStamina), energyCfg.MAX, Config.StaminaUpgrade.MAX_CAP)
	if type(raw.hookEnergy) == 'table' then
		profile.hookEnergy.maxHookEnergy = math.clamp(math.floor(tonumber(raw.hookEnergy.maxHookEnergy) or profile.hookEnergy.maxHookEnergy), Config.HookEnergy.MAX, Config.HookEnergyUpgrade.MAX_CAP)
		profile.hookEnergy.hookRegenPerSec = math.clamp(math.floor(tonumber(raw.hookEnergy.hookRegenPerSec) or profile.hookEnergy.hookRegenPerSec), Config.HookEnergy.REGEN_PER_SEC, Config.HookRegenUpgrade.MAX_CAP)
	end

	if type(raw.workshop) == 'table' then
		profile.workshop.ownedWeapons = normalizeStringArray(raw.workshop.ownedWeapons, profile.workshop.ownedWeapons)
		profile.workshop.ownedColors = normalizeStringArray(raw.workshop.ownedColors, profile.workshop.ownedColors)
		profile.workshop.ownedHookTips = normalizeStringArray(raw.workshop.ownedHookTips, profile.workshop.ownedHookTips)
		profile.workshop.ownedHookRopes = normalizeStringArray(raw.workshop.ownedHookRopes, profile.workshop.ownedHookRopes)
		if type(raw.workshop.equippedWeaponId) == 'string' then
			profile.workshop.equippedWeaponId = raw.workshop.equippedWeaponId
		end
		if type(raw.workshop.equippedLaserColorId) == 'string' then
			profile.workshop.equippedLaserColorId = raw.workshop.equippedLaserColorId
		end
		if type(raw.workshop.equippedHookTipId) == 'string' then
			profile.workshop.equippedHookTipId = raw.workshop.equippedHookTipId
		end
		if type(raw.workshop.equippedHookRopeId) == 'string' then
			profile.workshop.equippedHookRopeId = raw.workshop.equippedHookRopeId
		end
	end

	if type(raw.preferences) == 'table' then
		profile.preferences.battleOptOut = raw.preferences.battleOptOut == true
	end

	if type(raw.stats) == 'table' then
		profile.stats.eliminations = math.max(0, math.floor(tonumber(raw.stats.eliminations) or 0))
		profile.stats.limbsFrozen = math.max(0, math.floor(tonumber(raw.stats.limbsFrozen) or 0))
		profile.stats.matchesPlayed = math.max(0, math.floor(tonumber(raw.stats.matchesPlayed) or 0))
	end

	if type(raw.daily) == 'table' then
		profile.daily.lastClaimDay = math.max(0, math.floor(tonumber(raw.daily.lastClaimDay) or 0))
		profile.daily.streak = math.max(0, math.floor(tonumber(raw.daily.streak) or 0))
	end

	if type(raw.missions) == 'table' then
		profile.missions.lastRefreshDay = math.max(0, math.floor(tonumber(raw.missions.lastRefreshDay) or 0))
		if type(raw.missions.entries) == 'table' then
			profile.missions.entries = clone(raw.missions.entries)
		end
	end

	if type(raw.hook) == 'table' then
		if type(raw.hook.tipCosmeticId) == 'string' then
			profile.hook.tipCosmeticId = raw.hook.tipCosmeticId
		end
		if type(raw.hook.ropeCosmeticId) == 'string' then
			profile.hook.ropeCosmeticId = raw.hook.ropeCosmeticId
		end
	end

	return profile
end

local function waitForService(getter, timeout)
	local started = os.clock()
	while os.clock() - started < (timeout or 10) do
		local service = getter()
		if service then
			return service
		end
		task.wait(0.1)
	end
	return getter()
end

local function getCurrencyService()
	return waitForService(function()
		return _G.ZB and _G.ZB.CurrencyService
	end)
end

local function getWorkshopService()
	return waitForService(function()
		return _G.ZB and _G.ZB.Workshop
	end)
end

local function getStaminaService()
	return waitForService(function()
		return _G.ZB and _G.ZB.Stamina
	end)
end

local function getHookEnergyService()
	return waitForService(function()
		return _G.ZB and _G.ZB.HookEnergy
	end)
end

local function getRankService()
	return waitForService(function()
		return _G.ZB and _G.ZB.RankService
	end)
end

local function applyProfile(player, profile)
	local currency = getCurrencyService()
	local workshop = getWorkshopService()
	local stamina = getStaminaService()
	local rank = getRankService()
	local hookEnergy = getHookEnergyService()

	if currency and currency.setCoins then
		currency.setCoins(player, profile.coins)
	end
	if workshop and workshop.applyProfile then
		workshop.applyProfile(player, profile.workshop)
	end
	if stamina and stamina.setMax then
		stamina.setMax(player, profile.maxStamina, true)
	end
	if rank and rank.applyStats then
		rank.applyStats(player, profile.stats)
	end
	if hookEnergy and hookEnergy.setProfile then
		hookEnergy.setProfile(player, profile.hookEnergy.maxHookEnergy, profile.hookEnergy.hookRegenPerSec, true)
	end

	player:SetAttribute(matchCfg.OPT_OUT_ATTRIBUTE, profile.preferences.battleOptOut == true)
	player:SetAttribute('HookTipCosmeticId', profile.hook.tipCosmeticId)
	player:SetAttribute('HookRopeCosmeticId', profile.hook.ropeCosmeticId)
end

local function captureProfile(player)
	local current = loadedProfiles[player] and clone(loadedProfiles[player]) or clone(DEFAULT_PROFILE)
	local currency = getCurrencyService()
	local workshop = getWorkshopService()
	local stamina = getStaminaService()
	local rank = getRankService()
	local hookEnergy = getHookEnergyService()

	if currency and currency.getCoins then
		current.coins = currency.getCoins(player)
	end
	if workshop and workshop.getProfile then
		current.workshop = workshop.getProfile(player)
	end
	if stamina and stamina.getMax then
		current.maxStamina = stamina.getMax(player)
	end
	if rank and rank.getStats then
		current.stats = rank.getStats(player)
	end
	if hookEnergy and hookEnergy.getProfile then
		current.hookEnergy = hookEnergy.getProfile(player)
	end

	current.preferences.battleOptOut = player:GetAttribute(matchCfg.OPT_OUT_ATTRIBUTE) == true
	current.hook.tipCosmeticId = player:GetAttribute('HookTipCosmeticId') or current.hook.tipCosmeticId
	current.hook.ropeCosmeticId = player:GetAttribute('HookRopeCosmeticId') or current.hook.ropeCosmeticId
	return normalizeProfile(current)
end

local function profileKey(player)
	return 'player_' .. tostring(player.UserId)
end

local function savePlayer(player)
	if not loadedFlags[player] then return false end
	local snapshot = captureProfile(player)
	loadedProfiles[player] = clone(snapshot)
	if STUDIO_BYPASS_DATASTORE then
		return true
	end
	local ok, err = pcall(function()
		dataStore:SetAsync(profileKey(player), snapshot)
	end)
	if not ok then
		warn('[ZB Data] Error guardando a ' .. player.Name .. ': ' .. tostring(err))
	end
	return ok
end

local function loadPlayer(player)
	local profile = clone(DEFAULT_PROFILE)
	if not STUDIO_BYPASS_DATASTORE then
		local ok, stored = pcall(function()
			return dataStore:GetAsync(profileKey(player))
		end)
		if ok then
			profile = normalizeProfile(stored)
		else
			warn('[ZB Data] Error cargando a ' .. player.Name .. ': ' .. tostring(stored))
		end
	end
	loadedProfiles[player] = clone(profile)
	loadedFlags[player] = true
	applyProfile(player, profile)
end

local DataService = {}

function DataService.isLoaded(player)
	return loadedFlags[player] == true
end

function DataService.getProfile(player)
	return loadedProfiles[player] and clone(loadedProfiles[player]) or nil
end

function DataService.updateProfile(player, mutator)
	if not loadedProfiles[player] then return nil end
	local liveProfile = captureProfile(player)
	loadedProfiles[player] = clone(liveProfile)
	if type(mutator) == 'function' then
		mutator(loadedProfiles[player])
		loadedProfiles[player] = normalizeProfile(loadedProfiles[player])
	end
	applyProfile(player, loadedProfiles[player])
	return clone(loadedProfiles[player])
end

function DataService.save(player)
	return savePlayer(player)
end

for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(loadPlayer, player)
end

Players.PlayerAdded:Connect(function(player)
	task.spawn(loadPlayer, player)
end)

Players.PlayerRemoving:Connect(function(player)
	savePlayer(player)
	loadedProfiles[player] = nil
	loadedFlags[player] = nil
end)

task.spawn(function()
	while true do
		task.wait(AUTOSAVE_INTERVAL)
		for _, player in ipairs(Players:GetPlayers()) do
			savePlayer(player)
		end
	end
end)

game:BindToClose(function()
	for _, player in ipairs(Players:GetPlayers()) do
		savePlayer(player)
	end
end)

_G.ZB = _G.ZB or {}
_G.ZB.DataService = DataService
