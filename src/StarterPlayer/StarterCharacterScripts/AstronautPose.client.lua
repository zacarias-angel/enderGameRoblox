-- Tipo: LocalScript
-- Ubicación: StarterPlayer/StarterCharacterScripts/AstronautPose
-- Contexto: Cliente

--[[
	AstronautPose
	Genera una pose flotante de astronauta de forma procedural, sin animaciones
	subidas. Desactiva el script Animate por defecto y anima los Motor6D (C0)
	de hombros, caderas y cintura con ondas seno: brazos ligeramente abiertos,
	piernas relajadas y balanceo suave. Al acelerar, los brazos se inclinan
	hacia atrás. Es puramente visual/local (ReglasRoblox.md §6).
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local poseCfg = Config.Pose
local moveCfg = Config.Movement

local player = Players.LocalPlayer
local character = script.Parent

local joints = {}          -- [name] = { motor = Motor6D, base = CFrame }
local rootPart
local currentOffsets = {}  -- [name] = CFrame (offset suavizado actual)

local JOINT_NAMES = {
	"Waist", "LeftShoulder", "RightShoulder", "LeftHip", "RightHip",
}

local function stopDefaultAnimations(humanoid)
	-- Propósito: Desactivar Animate y detener pistas para liberar los Motor6D.
	-- Precondiciones:
	--   1. humanoid es el Humanoid del personaje local.
	-- Ubicación: StarterCharacterScripts/AstronautPose
	-- Retorna: nil
	local animate = character:FindFirstChild("Animate")
	if animate then
		animate.Disabled = true
	end
	local animator = humanoid:FindFirstChildOfClass("Animator")
	if animator then
		for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
			track:Stop(0)
		end
	end
end

local function cacheJoints()
	-- Propósito: Localizar los Motor6D relevantes y guardar su C0 base.
	-- Precondiciones:
	--   1. character contiene un rig R15 con Motor6D estándar.
	-- Ubicación: StarterCharacterScripts/AstronautPose
	-- Retorna: nil
	for _, motor in ipairs(character:GetDescendants()) do
		if motor:IsA("Motor6D") then
			for _, name in ipairs(JOINT_NAMES) do
				if motor.Name == name then
					joints[name] = { motor = motor, base = motor.C0 }
					currentOffsets[name] = CFrame.new()
				end
			end
		end
	end
end

local function computeSpeedRatio()
	-- Propósito: Ratio 0..1 de la velocidad actual respecto a la máxima.
	-- Precondiciones:
	--   1. rootPart válido.
	-- Ubicación: StarterCharacterScripts/AstronautPose
	-- Retorna: number 0..1
	if not rootPart then return 0 end
	return math.clamp(rootPart.AssemblyLinearVelocity.Magnitude / moveCfg.MAX_SPEED, 0, 1)
end

local function targetOffsets(t, speedRatio)
	-- Propósito: Calcular el offset objetivo (CFrame) de cada joint este frame.
	-- Precondiciones:
	--   1. t es el tiempo acumulado; speedRatio 0..1.
	-- Ubicación: StarterCharacterScripts/AstronautPose
	-- Retorna: table [name] = CFrame
	local wave = math.sin(t * poseCfg.BOB_SPEED)
	local wave2 = math.sin(t * poseCfg.BOB_SPEED + math.pi)

	local spread = math.rad(poseCfg.ARM_SPREAD_DEG)
	local armSwing = math.rad(poseCfg.ARM_SWING_DEG) * wave
	local legSwing = math.rad(poseCfg.LEG_SWING_DEG) * wave
	local torsoBob = math.rad(poseCfg.TORSO_BOB_DEG) * wave
	local lean = math.rad(poseCfg.MOVE_LEAN_DEG) * speedRatio

	return {
		-- Cintura: leve balanceo + ligera inclinación al moverse.
		Waist = CFrame.Angles(torsoBob * 0.5 - lean * 0.4, 0, torsoBob),
		-- Brazos abiertos hacia afuera (Z), swing adelante/atrás (X) + lean atrás.
		LeftShoulder = CFrame.Angles(armSwing - lean, 0, spread),
		RightShoulder = CFrame.Angles(-armSwing - lean, 0, -spread),
		-- Piernas relajadas con balanceo alterno.
		LeftHip = CFrame.Angles(legSwing, 0, math.rad(4)),
		RightHip = CFrame.Angles(-legSwing, 0, -math.rad(4)),
	}
end

local function onRenderStepped(dt)
	-- Propósito: Interpolar suavemente los C0 hacia la pose objetivo.
	-- Precondiciones:
	--   1. joints cacheados.
	-- Ubicación: StarterCharacterScripts/AstronautPose
	-- Retorna: nil
	if not next(joints) then return end

	local t = os.clock()
	local speedRatio = computeSpeedRatio()
	local targets = targetOffsets(t, speedRatio)
	local alpha = math.clamp(poseCfg.SMOOTHING * dt, 0, 1)

	for name, data in pairs(joints) do
		if data.motor.Parent then
			local target = targets[name] or CFrame.new()
			currentOffsets[name] = currentOffsets[name]:Lerp(target, alpha)
			data.motor.C0 = data.base * currentOffsets[name]
		end
	end
end

local function setup()
	-- Propósito: Inicializar la pose procedural al aparecer el personaje.
	-- Precondiciones:
	--   1. character es el modelo del personaje local.
	-- Ubicación: StarterCharacterScripts/AstronautPose
	-- Retorna: nil
	local humanoid = character:WaitForChild("Humanoid")
	rootPart = character:WaitForChild("HumanoidRootPart")
	-- Esperar a que el rig cargue sus Motor6D.
	character:WaitForChild("UpperTorso", 5)
	task.wait(0.1)
	stopDefaultAnimations(humanoid)
	cacheJoints()
end

setup()
RunService.RenderStepped:Connect(onRenderStepped)
