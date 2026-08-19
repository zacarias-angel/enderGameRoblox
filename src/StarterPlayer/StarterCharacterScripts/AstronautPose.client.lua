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
	Solo se activa en BATTLE o DUEL. En LOBBY, el personaje usa las
	animaciones por defecto (caminar, correr, idle).
	Escucha GameModeChanged para activar/desactivar en caliente.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local poseCfg = Config.Pose
local moveCfg = Config.Movement
local modeCfg = Config.GameMode

-- IDs de las animaciones oficiales R15 de natación de Roblox.
local SWIM_ANIM_ID = "rbxassetid://913384386"

local player = Players.LocalPlayer
local character = script.Parent

local rootPart
local humanoid

-- Estado modo procedural
local joints = {}          -- [name] = { motor = Motor6D, base = CFrame }
local currentOffsets = {}  -- [name] = CFrame (offset suavizado actual)
local JOINT_NAMES = {
	"Waist", "LeftShoulder", "RightShoulder", "LeftHip", "RightHip",
}

-- Estado modo swim
local swimTrack
local zeroGActive = false  -- true si estamos en modo 0g (BATTLE/DUEL)
local animGuardConn = nil -- conexión del guardia de AnimationPlayed

local function shouldActivate()
	-- Propósito: Saber si el modo actual es 0g.
	-- Precondiciones: ninguna.
	-- Ubicación: StarterCharacterScripts/AstronautPose
	-- Retorna: boolean
	local mode = player:GetAttribute("GameMode") or modeCfg.LOBBY
	return mode == modeCfg.BATTLE or mode == modeCfg.DUEL
end

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

local function stopDefaultAnimations()
	-- Propósito: Desactivar el script Animate por defecto para que las
	--            animaciones de caminar no peleen con la flotación.
	-- Precondiciones:
	--   1. character y humanoid válidos.
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
	if animGuardConn then
		animGuardConn:Disconnect()
		animGuardConn = nil
	end
	animGuardConn = humanoid.AnimationPlayed:Connect(function(track)
		if not isOwnTrack(track) and not isAllowedForeignTrack(track) then
			track:Stop(0)
		end
	end)
end

local function enableNormalAnimations()
	-- Propósito: Reactivar el script Animate para caminar/idle en LOBBY.
	-- Precondiciones:
	--   1. character válido.
	-- Ubicación: StarterCharacterScripts/AstronautPose
	-- Retorna: nil
	local animate = character:FindFirstChild("Animate")
	if animate then
		animate.Disabled = false
	end

	-- Desconectar el guardia que mata animaciones ajenas al 0g para que
	-- las animaciones de caminar/correr vuelvan a reproducirse en el lobby.
	if animGuardConn then
		animGuardConn:Disconnect()
		animGuardConn = nil
	end

	-- Humanoid a estado Running para que Animate tome el control.
	if humanoid then
		humanoid:ChangeState(Enum.HumanoidStateType.Running)
	end
end

local function deactivateZeroG()
	-- Propósito: Desactivar el modo 0g: parar natación, restaurar Animate.
	-- Precondiciones: ninguna.
	-- Ubicación: StarterCharacterScripts/AstronautPose
	-- Retorna: nil
	if not zeroGActive then return end
	zeroGActive = false

	if swimTrack then
		swimTrack:Stop(0.3)
	end

	enableNormalAnimations()
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

local function setupSwim()
	-- Propósito: Cargar y arrancar la animación de natación en bucle, a
	--            velocidad fija y lenta, tanto en reposo como en movimiento.
	-- Precondiciones:
	--   1. humanoid es el Humanoid del personaje local.
	-- Ubicación: StarterCharacterScripts/AstronautPose
	-- Retorna: nil
	if not humanoid then return end
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

local function activateZeroG()
	-- Propósito: Activar el modo 0g: desactivar Animate, iniciar natación.
	-- Precondiciones: ninguna.
	-- Ubicación: StarterCharacterScripts/AstronautPose
	-- Retorna: nil
	if zeroGActive then return end
	zeroGActive = true

	if not humanoid then return end

	stopDefaultAnimations()

	if poseCfg.MODE == "swim" then
		setupSwim()
	else
		cacheJoints()
	end
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
	--            Solo ejecuta si estamos en modo 0g (BATTLE/DUEL).
	-- Precondiciones: ninguna.
	-- Ubicación: StarterCharacterScripts/AstronautPose
	-- Retorna: nil
	if not zeroGActive then return end

	if poseCfg.MODE == "swim" then
		updateSwim(dt)
	else
		updateProcedural(dt)
	end
end

local function setup()
	-- Propósito: Inicializar según el modo actual al aparecer el personaje.
	--            En LOBBY: el personaje usa animaciones normales.
	--            En BATTLE/DUEL: activa la pose de flotación.
	-- Precondiciones:
	--   1. character es el modelo del personaje local.
	-- Ubicación: StarterCharacterScripts/AstronautPose
	-- Retorna: nil
	humanoid = character:WaitForChild("Humanoid")
	rootPart = character:WaitForChild("HumanoidRootPart")
	character:WaitForChild("UpperTorso", 5)
	task.wait(0.1)

	if shouldActivate() then
		activateZeroG()
	end
end

-- Escuchar cambios de modo para activar/desactivar la pose en caliente.
local modeChanged = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("GameModeChanged")
modeChanged.OnClientEvent:Connect(function(mode)
	if mode == modeCfg.BATTLE or mode == modeCfg.DUEL then
		activateZeroG()
	else
		deactivateZeroG()
	end
end)

setup()
RunService.RenderStepped:Connect(onRenderStepped)
