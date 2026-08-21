-- Tipo: LocalScript
-- Ubicación: StarterPlayer/StarterPlayerScripts/GravityController
-- Contexto: Cliente

--[[
	GravityController
	Escucha el RemoteEvent GameModeChanged del servidor y ajusta el
	comportamiento del cliente según el modo activo.
	- LOBBY: permite caminar normal, desactiva propulsores 0g.
	- BATTLE / DUEL: activa los propulsores y el movimiento en 0g.
	El personaje se reconfigura cuando cambia el modo activo.
	Este script NO reemplaza a ZeroGSetup: se coordina con él.
	ZeroGSetup configura la física base; este script la activa/desactiva
	según el modo actual.
]]

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
	-- Propósito: Saber si un modo usa gravedad cero.
	-- Precondiciones:
	--   1. mode es un string de Config.GameMode.
	-- Ubicación: StarterPlayerScripts/GravityController
	-- Retorna: boolean
	return mode == modeCfg.BATTLE or mode == modeCfg.DUEL
end

local function enableWalking(character)
	-- Propósito: Reactivar el caminar normal para el lobby.
	-- Precondiciones:
	--   1. character es el modelo del personaje local.
	-- Ubicación: StarterPlayerScripts/GravityController
	-- Retorna: nil
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then return end
	humanoid.WalkSpeed = 16
	humanoid.JumpPower = 50
	humanoid.AutoRotate = true
	humanoid.PlatformStand = false
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, true)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, true)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
	humanoid:ChangeState(Enum.HumanoidStateType.Running)

	-- Liberar el rootPart si estaba anclado.
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
		-- Desactivar el AlignOrientation 0g para que no pelee con el
		-- AutoRotate del Humanoid al caminar en el lobby.
		local align = rootPart:FindFirstChild("ZB_AlignOrientation")
		if align and align:IsA("AlignOrientation") then
			align.Enabled = false
		end
	end
end

local function enableZeroG(character)
	-- Propósito: Activar el movimiento 0g para batalla/duelo.
	-- Precondiciones:
	--   1. character es el modelo del personaje local.
	--   2. ZeroGSetup ya creó los objetos de física (ZB_ThrustForce, etc.).
	-- Ubicación: StarterPlayerScripts/GravityController
	-- Retorna: nil
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then return end

	-- Asegurar que las físicas 0g estén presentes (ZeroGSetup las crea).
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return end
	local lobbyGravity = rootPart:FindFirstChild("ZB_LobbyGravityForce")
	if lobbyGravity and lobbyGravity:IsA("VectorForce") then
		lobbyGravity.Force = Vector3.zero
	end
	if not rootPart:FindFirstChild("ZB_ThrustForce") then
		-- ZeroGSetup no ha corrido aún; esperar y reintentar.
		task.wait(0.3)
		if not rootPart:FindFirstChild("ZB_ThrustForce") then return end
	end

	humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)

	-- Reactivar el AlignOrientation 0g (se desactiva al volver al lobby).
	local align = rootPart:FindFirstChild("ZB_AlignOrientation")
	if align and align:IsA("AlignOrientation") then
		align.Enabled = true
	end
end

local function onModeChanged(mode, prevMode)
	-- Propósito: Reaccionar a un cambio de modo desde el servidor.
	-- Precondiciones:
	--   1. mode y prevMode son strings válidos.
	-- Ubicación: StarterPlayerScripts/GravityController
	-- Retorna: nil
	currentMode = mode

	local character = player.Character
	if not character then return end

	if isZeroG(mode) and isBattleParticipant() then
		enableZeroG(character)
	else
		enableWalking(character)
	end

	-- Actualizar atributo para que MovementController lo lea.
	player:SetAttribute("GameMode", mode)
end

-- Conexiones
local modeChanged = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("GameModeChanged")
modeChanged.OnClientEvent:Connect(onModeChanged)

-- Sincronizar con el personaje actual (ya cargado al iniciar el script).
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
