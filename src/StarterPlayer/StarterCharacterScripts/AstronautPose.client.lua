-- Tipo: LocalScript
-- Ubicación: StarterPlayer/StarterCharacterScripts/AstronautPose
-- Contexto: Cliente

--[[
	AstronautPose
	Da al jugador su animación de flotación en 0g. Soporta dos modos
	(Config.Pose.MODE):
	  "swim"       -> reproduce las animaciones oficiales de natación de Roblox
	                  (swim + swimidle) con crossfade según la velocidad.
	  "procedural" -> pose generada por código animando los Motor6D (C0) con
	                  ondas seno.
	En ambos casos desactiva el script Animate por defecto para evitar que las
	animaciones de caminar/idle peleen con la flotación. Es visual/local.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local poseCfg = Config.Pose
local moveCfg = Config.Movement

-- IDs de las animaciones oficiales R15 de natación de Roblox.
local SWIM_ANIM_ID = "rbxassetid://913384386"

local player = Players.LocalPlayer
local character = script.Parent

local rootPart

-- Estado modo procedural
local joints = {}          -- [name] = { motor = Motor6D, base = CFrame }
local currentOffsets = {}  -- [name] = CFrame (offset suavizado actual)
local JOINT_NAMES = {
	"Waist", "LeftShoulder", "RightShoulder", "LeftHip", "RightHip",
}

-- Estado modo swim
local swimTrack

local function isOwnTrack(track)
	-- Propósito: Saber si una pista es de nuestras animaciones de flotación.
	-- Precondiciones: ninguna.
	-- Ubicación: StarterCharacterScripts/AstronautPose
	-- Retorna: boolean
	return track == swimTrack
end

local function isAllowedForeignTrack(track)
	-- Propósito: Permitir pistas externas legítimas (ej. pose de agarre) que no
	--            deben ser detenidas por el guardia.
	-- Precondiciones:
	--   1. track es un AnimationTrack.
	-- Ubicación: StarterCharacterScripts/AstronautPose
	-- Retorna: boolean
	local anim = track.Animation
	if anim and anim.AnimationId == Config.Grab.POSE_ANIM_ID then
		return true
	end
	return false
end

local function stopDefaultAnimations(humanoid)
	-- Propósito: Desactivar el script Animate por defecto y matar cualquier
	--            pista ajena (caminar/idle) que intente reproducirse, incluso
	--            si Animate se inserta tarde.
	-- Precondiciones:
	--   1. humanoid es el Humanoid del personaje local.
	-- Ubicación: StarterCharacterScripts/AstronautPose
	-- Retorna: nil
	local animate = character:WaitForChild("Animate", 5)
	if animate then
		animate.Disabled = true
	end

	local animator = humanoid:FindFirstChildOfClass("Animator")
	if animator then
		for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
			if not isOwnTrack(track) and not isAllowedForeignTrack(track) then
				track:Stop(0)
			end
		end
	end

	-- Guardia continua: si alguna pista ajena arranca, la detenemos.
	humanoid.AnimationPlayed:Connect(function(track)
		if not isOwnTrack(track) and not isAllowedForeignTrack(track) then
			track:Stop(0)
		end
	end)
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

-- ===== Modo SWIM =====

local function setupSwim(humanoid)
	-- Propósito: Cargar y arrancar la animación de natación en bucle, a
	--            velocidad fija y lenta, tanto en reposo como en movimiento.
	-- Precondiciones:
	--   1. humanoid es el Humanoid del personaje local.
	-- Ubicación: StarterCharacterScripts/AstronautPose
	-- Retorna: nil
	local animator = humanoid:FindFirstChildOfClass("Animator")
	if not animator then
		animator = Instance.new("Animator")
		animator.Parent = humanoid
	end

	local swimAnim = Instance.new("Animation")
	swimAnim.AnimationId = SWIM_ANIM_ID

	swimTrack = animator:LoadAnimation(swimAnim)
	swimTrack.Looped = true
	swimTrack.Priority = Enum.AnimationPriority.Action

	swimTrack:Play(0.3)
	swimTrack:AdjustWeight(1, 0.3)
	swimTrack:AdjustSpeed(poseCfg.SWIM_SPEED)
end

local function updateSwim(dt)
	-- Propósito: Mantener la brazada a velocidad fija lenta e igual siempre,
	--            sin acelerar al moverse. Reafirma peso/velocidad por si otra
	--            animación intenta interferir. Se silencia mientras el jugador
	--            está aferrado (para dejar ver la pose de agarre).
	-- Precondiciones:
	--   1. swimTrack cargado.
	-- Ubicación: StarterCharacterScripts/AstronautPose
	-- Retorna: nil
	if not swimTrack then return end

	if player:GetAttribute("Grabbing") then
		swimTrack:AdjustWeight(0.001, 0.15)
		return
	end

	if not swimTrack.IsPlaying then
		swimTrack:Play(0.3)
	end
	swimTrack:AdjustWeight(1, 0.1)
	swimTrack:AdjustSpeed(poseCfg.SWIM_SPEED)
end

-- ===== Modo PROCEDURAL =====

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

local function targetOffsets(t, speedRatio)
	-- Propósito: Calcular el offset objetivo (CFrame) de cada joint este frame.
	-- Precondiciones:
	--   1. t es el tiempo acumulado; speedRatio 0..1.
	-- Ubicación: StarterCharacterScripts/AstronautPose
	-- Retorna: table [name] = CFrame
	local wave = math.sin(t * poseCfg.BOB_SPEED)

	local spread = math.rad(poseCfg.ARM_SPREAD_DEG)
	local armSwing = math.rad(poseCfg.ARM_SWING_DEG) * wave
	local legSwing = math.rad(poseCfg.LEG_SWING_DEG) * wave
	local torsoBob = math.rad(poseCfg.TORSO_BOB_DEG) * wave
	local lean = math.rad(poseCfg.MOVE_LEAN_DEG) * speedRatio

	return {
		Waist = CFrame.Angles(torsoBob * 0.5 - lean * 0.4, 0, torsoBob),
		LeftShoulder = CFrame.Angles(armSwing - lean, 0, spread),
		RightShoulder = CFrame.Angles(-armSwing - lean, 0, -spread),
		LeftHip = CFrame.Angles(legSwing, 0, math.rad(4)),
		RightHip = CFrame.Angles(-legSwing, 0, -math.rad(4)),
	}
end

local function updateProcedural(dt)
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

-- ===== Bucle y arranque =====

local function onRenderStepped(dt)
	-- Propósito: Actualizar la animación de flotación según el modo activo.
	-- Precondiciones: ninguna.
	-- Ubicación: StarterCharacterScripts/AstronautPose
	-- Retorna: nil
	if poseCfg.MODE == "swim" then
		updateSwim(dt)
	else
		updateProcedural(dt)
	end
end

local function setup()
	-- Propósito: Inicializar el modo de flotación al aparecer el personaje.
	-- Precondiciones:
	--   1. character es el modelo del personaje local.
	-- Ubicación: StarterCharacterScripts/AstronautPose
	-- Retorna: nil
	local humanoid = character:WaitForChild("Humanoid")
	rootPart = character:WaitForChild("HumanoidRootPart")
	character:WaitForChild("UpperTorso", 5)
	task.wait(0.1)
	stopDefaultAnimations(humanoid)

	if poseCfg.MODE == "swim" then
		setupSwim(humanoid)
	else
		cacheJoints()
	end
end

setup()
RunService.RenderStepped:Connect(onRenderStepped)
