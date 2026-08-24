-- Tipo: Script
-- Ubicación: ServerScriptService/GameModeService
-- Contexto: Servidor

--[[
	GameModeService
	Gestiona el modo de juego actual (LOBBY, BATTLE, DUEL) y controla la
	gravedad del workspace según el modo activo.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local modeCfg = Config.GameMode

local currentMode = modeCfg.DEFAULT

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

local modeChanged = ensureRemote("GameModeChanged")

local function isZeroG(mode)
	return mode == modeCfg.BATTLE or mode == modeCfg.DUEL
end

local function applyGravity(mode)
	if isZeroG(mode) then
		workspace.Gravity = modeCfg.ZERO_GRAVITY
	else
		workspace.Gravity = modeCfg.NORMAL_GRAVITY
	end
end

local GameMode = {}

function GameMode.getMode()
	return currentMode
end

function GameMode.isZeroG()
	return isZeroG(currentMode)
end

function GameMode.setMode(mode)
	if mode ~= modeCfg.LOBBY and mode ~= modeCfg.BATTLE and mode ~= modeCfg.DUEL then
		return
	end
	if mode == currentMode then return end

	local prevMode = currentMode
	currentMode = mode

	applyGravity(mode)
	modeChanged:FireAllClients(mode, prevMode)

	if _G.ZB then
		if _G.ZB.RankService and mode ~= modeCfg.LOBBY then
			_G.ZB.RankService.onModeStarted(mode)
		end
		if _G.ZB.PlayerState and mode == modeCfg.LOBBY then
			for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
				_G.ZB.PlayerState.reset(player)
			end
		end
	end
end

applyGravity(currentMode)

_G.ZB = _G.ZB or {}
_G.ZB.GameMode = GameMode
