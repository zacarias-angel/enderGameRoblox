-- Tipo: LocalScript
-- Ubicación: StarterPlayer/StarterPlayerScripts/GravityController
-- Contexto: Cliente

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local modeCfg = Config.GameMode

local player = Players.LocalPlayer
local currentMode = modeCfg.LOBBY
local PARTICIPANT_ATTRIBUTE = "BattleParticipant"

local function isBattleParticipant()
	return player:GetAttribute(PARTICIPANT_ATTRIBUTE) == true
end

local function ensureLobbyGravity(rootPart)
	local attachment = rootPart:FindFirstChild("ZB_LobbyGravityAttachment")
	if not attachment then
		attachment = Instance.new("Attachment")
		attachment.Name = "ZB_LobbyGravityAttachment"
		attachment.Parent = rootPart
	end

	local force = rootPart:FindFirstChild("ZB_LobbyGravityForce")
	if not force then
		force = Instance.new("VectorForce")
		force.Name = "ZB_LobbyGravityForce"
		force.Attachment0 = attachment
		force.RelativeTo = Enum.ActuatorRelativeTo.World
		force.ApplyAtCenterOfMass = true
		force.Parent = rootPart
	end

	return force
end

local function isZeroG(mode)
	return mode == modeCfg.BATTLE or mode == modeCfg.DUEL
end

local function enableWalking(character)
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then return end
	humanoid.WalkSpeed = 16
	humanoid.JumpPower = 50
	humanoid.JumpHeight = 7.2
	humanoid.AutoRotate = true
	humanoid.PlatformStand = false
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, true)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, true)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
	humanoid:ChangeState(Enum.HumanoidStateType.Running)

	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if rootPart then
		rootPart.Anchored = false
		local lobbyGravity = ensureLobbyGravity(rootPart)
		if workspace.Gravity == 0 then
			lobbyGravity.Force = Vector3.new(0, -modeCfg.NORMAL_GRAVITY * rootPart.AssemblyMass, 0)
		else
			lobbyGravity.Force = Vector3.zero
		end
		local force = rootPart:FindFirstChild("ZB_ThrustForce")
		if force and force:IsA("VectorForce") then
			force.Force = Vector3.zero
		end
		local align = rootPart:FindFirstChild("ZB_AlignOrientation")
		if align and align:IsA("AlignOrientation") then
			align.Enabled = false
		end
	end
end

local function enableZeroG(character)
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then return end

	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return end
	local lobbyGravity = rootPart:FindFirstChild("ZB_LobbyGravityForce")
	if lobbyGravity and lobbyGravity:IsA("VectorForce") then
		lobbyGravity.Force = Vector3.zero
	end
	if not rootPart:FindFirstChild("ZB_ThrustForce") then
		task.wait(0.3)
		if not rootPart:FindFirstChild("ZB_ThrustForce") then return end
	end

	humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)

	local align = rootPart:FindFirstChild("ZB_AlignOrientation")
	if align and align:IsA("AlignOrientation") then
		align.Enabled = true
	end
end

local function onModeChanged(mode, prevMode)
	currentMode = mode

	local character = player.Character
	if not character then return end

	if isZeroG(mode) and isBattleParticipant() then
		enableZeroG(character)
	else
		enableWalking(character)
	end

	player:SetAttribute("GameMode", mode)
end

local modeChanged = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("GameModeChanged")
modeChanged.OnClientEvent:Connect(onModeChanged)

if player.Character then
	onModeChanged(currentMode)
end
player.CharacterAdded:Connect(function(char)
	task.wait(0.2)
	onModeChanged(currentMode)
end)

player:GetAttributeChangedSignal(PARTICIPANT_ATTRIBUTE):Connect(function()
	onModeChanged(currentMode)
end)
