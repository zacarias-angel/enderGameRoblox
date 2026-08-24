-- Tipo: Script
-- Ubicación: ServerScriptService/PlayerStateService
-- Contexto: Servidor

--[[
	PlayerStateService
	Fuente de verdad del estado de combate de cada jugador: extremidades
	congeladas y si está eliminado. Expone una API (vía _G.ZB.PlayerState y
	BindableFunction interno) para que FreezeService y ShootingService la usen,
	y replica el estado al cliente mediante StateChanged.
	Toda mutación de estado ocurre aquí, en el servidor. Ver ReglasRoblox.md §4.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))

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

local stateChanged = ensureRemote("StateChanged")
local states = {}
local PlayerState = {}

local function freshState()
	return {
		[Config.Limb.LEFT_ARM] = Config.LimbState.OK,
		[Config.Limb.RIGHT_ARM] = Config.LimbState.OK,
		[Config.Limb.LEFT_LEG] = Config.LimbState.OK,
		[Config.Limb.RIGHT_LEG] = Config.LimbState.OK,
		eliminated = false,
	}
end

function PlayerState.get(player)
	if not states[player] then
		states[player] = freshState()
	end
	return states[player]
end

function PlayerState.reset(player)
	states[player] = freshState()
	PlayerState.replicate(player)
end

function PlayerState.isAlive(player)
	return not PlayerState.get(player).eliminated
end

function PlayerState.setLimb(player, limbKey, limbState)
	local state = PlayerState.get(player)
	if state[limbKey] == nil then return end
	state[limbKey] = limbState
	PlayerState.replicate(player)
end

function PlayerState.eliminate(player)
	local state = PlayerState.get(player)
	state.eliminated = true
	PlayerState.replicate(player)
end

function PlayerState.replicate(player)
	if not player or not player.Parent then return end
	stateChanged:FireClient(player, PlayerState.get(player))
end

Players.PlayerAdded:Connect(function(player)
	PlayerState.reset(player)
	player.CharacterAdded:Connect(function()
		task.wait(0.2)
		PlayerState.reset(player)
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	states[player] = nil
end)

_G.ZB = _G.ZB or {}
_G.ZB.PlayerState = PlayerState
