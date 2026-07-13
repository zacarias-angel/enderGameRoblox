-- Tipo: LocalScript
-- Ubicación: StarterPlayer/StarterCharacterScripts/ZeroGSetup
-- Contexto: Cliente

--[[
	ZeroGSetup
	Prepara el personaje para gravedad cero: desactiva el caminar del Humanoid
	y crea los objetos de física (VectorForce + AlignOrientation) que
	MovementController usará para propulsar y orientar al jugador.
	La orientación se deja fluida (responsiveness bajo): MovementController
	actualiza el CFrame objetivo cada frame para seguir la cámara e inclinar.
	Solo configura la física local; la autoridad de gameplay es del servidor.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local orientCfg = Config.Orientation

local player = Players.LocalPlayer
local character = script.Parent

local FORCE_NAME = "ZB_ThrustForce"
local ALIGN_NAME = "ZB_AlignOrientation"
local ATTACH_NAME = "ZB_ThrustAttachment"

local function disableWalking(humanoid)
	-- Propósito: Evitar que el Humanoid camine/salte/trepe en 0g.
	-- Precondiciones:
	--   1. humanoid es un Humanoid válido del personaje local.
	-- Ubicación: StarterCharacterScripts/ZeroGSetup
	-- Retorna: nil
	humanoid.WalkSpeed = 0
	humanoid.JumpPower = 0
	humanoid.JumpHeight = 0
	humanoid.AutoRotate = false
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
	humanoid:ChangeState(Enum.HumanoidStateType.Physics)
end

local function buildPhysics(rootPart)
	-- Propósito: Crear Attachment + VectorForce + AlignOrientation en el root.
	-- Precondiciones:
	--   1. rootPart es el HumanoidRootPart del personaje local.
	-- Ubicación: StarterCharacterScripts/ZeroGSetup
	-- Retorna: nil (los objetos quedan parentados al rootPart)
	if rootPart:FindFirstChild(ATTACH_NAME) then
		return
	end

	local attachment = Instance.new("Attachment")
	attachment.Name = ATTACH_NAME
	attachment.Parent = rootPart

	local force = Instance.new("VectorForce")
	force.Name = FORCE_NAME
	force.Attachment0 = attachment
	force.RelativeTo = Enum.ActuatorRelativeTo.World
	force.ApplyAtCenterOfMass = true
	force.Force = Vector3.zero
	force.Parent = rootPart

	local align = Instance.new("AlignOrientation")
	align.Name = ALIGN_NAME
	align.Attachment0 = attachment
	align.Mode = Enum.OrientationAlignmentMode.OneAttachment
	align.RigidityEnabled = false
	align.MaxTorque = orientCfg.MAX_TORQUE
	align.MaxAngularVelocity = math.huge
	align.Responsiveness = orientCfg.RESPONSIVENESS
	-- CFrame inicial: mantener la orientación actual del root (evita saltos).
	align.CFrame = rootPart.CFrame
	align.Parent = rootPart
end

local function setup()
	-- Propósito: Ejecutar la configuración completa al aparecer el personaje.
	-- Precondiciones:
	--   1. character es el modelo del personaje local.
	-- Ubicación: StarterCharacterScripts/ZeroGSetup
	-- Retorna: nil
	local humanoid = character:WaitForChild("Humanoid")
	local rootPart = character:WaitForChild("HumanoidRootPart")
	disableWalking(humanoid)
	buildPhysics(rootPart)
end

setup()
