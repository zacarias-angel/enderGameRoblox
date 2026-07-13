-- Tipo: LocalScript
-- Ubicación: StarterPlayer/StarterPlayerScripts/MovementController
-- Contexto: Cliente

--[[
	MovementController
	Traduce el input del jugador en empuje sobre el VectorForce creado por
	ZeroGSetup, produciendo movimiento con inercia en 6 direcciones + Boost.
	Gestiona la energía de boost localmente y expone su valor para el HUD.
	Escucha StateChanged para reducir el empuje si hay piernas congeladas.
	El movimiento es client-owned (estándar Roblox); el gameplay real (daño,
	congelación) lo valida el servidor.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local moveCfg = Config.Movement
local energyCfg = Config.Energy
local orientCfg = Config.Orientation

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Estado local de movimiento
local character, humanoid, rootPart, thrustForce, alignOrient
local frozenLegs = { left = false, right = false }
local eliminated = false
local smoothedThrust = Vector3.zero

-- Energía compartida con el HUD vía atributo del jugador
player:SetAttribute("BoostEnergy", energyCfg.MAX)

local function bindCharacter(char)
	-- Propósito: Cachear referencias del personaje y su VectorForce.
	-- Precondiciones:
	--   1. char es el modelo del personaje local.
	-- Ubicación: StarterPlayerScripts/MovementController
	-- Retorna: nil
	character = char
	humanoid = char:WaitForChild("Humanoid")
	rootPart = char:WaitForChild("HumanoidRootPart")
	thrustForce = rootPart:WaitForChild("ZB_ThrustForce")
	alignOrient = rootPart:WaitForChild("ZB_AlignOrientation")
	frozenLegs.left = false
	frozenLegs.right = false
	eliminated = false
	smoothedThrust = Vector3.zero
end

local function getInputVector()
	-- Propósito: Calcular la dirección deseada relativa a la cámara.
	-- Precondiciones:
	--   1. camera existe.
	-- Ubicación: StarterPlayerScripts/MovementController
	-- Retorna: Vector3 unitario (o cero si no hay input)
	local move = Vector3.zero
	local look = camera.CFrame.LookVector
	local right = camera.CFrame.RightVector
	local up = Vector3.new(0, 1, 0)

	if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += look end
	if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= look end
	if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += right end
	if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= right end
	if UserInputService:IsKeyDown(moveCfg.VERTICAL_KEY_UP) then move += up end
	if UserInputService:IsKeyDown(moveCfg.VERTICAL_KEY_DOWN) then move -= up end

	if move.Magnitude > 0 then
		move = move.Unit
	end
	return move
end

local function legMultiplier()
	-- Propósito: Reducir el empuje según piernas congeladas.
	-- Precondiciones: ninguna.
	-- Ubicación: StarterPlayerScripts/MovementController
	-- Retorna: number multiplicador de empuje.
	local count = 0
	if frozenLegs.left then count += 1 end
	if frozenLegs.right then count += 1 end
	if count >= 2 then
		return moveCfg.LEG_TWO_FROZEN_MULT
	elseif count == 1 then
		return moveCfg.LEG_ONE_FROZEN_MULT
	end
	return 1
end

local function updateOrientation(dt)
	-- Propósito: Orientar el cuerpo hacia la cámara e inclinarlo (banking)
	--            según la velocidad, dando una flotación fluida y natural.
	-- Precondiciones:
	--   1. alignOrient y rootPart válidos.
	-- Ubicación: StarterPlayerScripts/MovementController
	-- Retorna: nil
	if not alignOrient or not alignOrient.Parent or not rootPart then
		return
	end

	local camCFrame = camera.CFrame
	local lookFlat = camCFrame.LookVector
	-- Base: mirar en la dirección horizontal de la cámara.
	local baseCFrame = CFrame.lookAt(rootPart.Position, rootPart.Position + lookFlat)

	-- Inclinación (banking) proporcional a la velocidad lateral/vertical.
	local velocity = rootPart.AssemblyLinearVelocity
	local speedRatio = math.clamp(velocity.Magnitude / orientCfg.TILT_SPEED_REF, 0, 1)
	local localVel = baseCFrame:VectorToObjectSpace(velocity)
	local maxTilt = math.rad(orientCfg.TILT_MAX_DEG) * speedRatio
	local pitch = -math.clamp(localVel.Z / orientCfg.TILT_SPEED_REF, -1, 1) * maxTilt
	local roll = -math.clamp(localVel.X / orientCfg.TILT_SPEED_REF, -1, 1) * maxTilt

	alignOrient.CFrame = baseCFrame * CFrame.Angles(pitch, 0, roll)
end

local function updateEnergy(dt, wantsBoost)
	-- Propósito: Consumir o regenerar energía de boost y devolver si aplica.
	-- Precondiciones:
	--   1. dt es el delta de tiempo del frame.
	-- Ubicación: StarterPlayerScripts/MovementController
	-- Retorna: boolean (true si el boost está activo este frame)
	local energy = player:GetAttribute("BoostEnergy") or energyCfg.MAX
	local boosting = false

	if wantsBoost and energy > energyCfg.MIN_TO_BOOST then
		energy = math.max(0, energy - energyCfg.BOOST_DRAIN_PER_SEC * dt)
		boosting = true
	else
		energy = math.min(energyCfg.MAX, energy + energyCfg.REGEN_PER_SEC * dt)
	end

	player:SetAttribute("BoostEnergy", energy)
	return boosting
end

local function onHeartbeat(dt)
	-- Propósito: Aplicar empuje con inercia, drag y clamp de velocidad.
	-- Precondiciones:
	--   1. Personaje y VectorForce válidos.
	-- Ubicación: StarterPlayerScripts/MovementController
	-- Retorna: nil
	if not rootPart or not thrustForce or not thrustForce.Parent then
		return
	end

	if eliminated then
		thrustForce.Force = Vector3.zero
		smoothedThrust = Vector3.zero
		return
	end

	-- Mientras se está aferrado, GrabController controla posición y orientación.
	if player:GetAttribute("Grabbing") then
		thrustForce.Force = Vector3.zero
		smoothedThrust = Vector3.zero
		return
	end

	updateOrientation(dt)

	local wantsBoost = UserInputService:IsKeyDown(moveCfg.BOOST_KEY)
	local boosting = updateEnergy(dt, wantsBoost)

	local direction = getInputVector()
	local velocity = rootPart.AssemblyLinearVelocity

	-- Empuje objetivo
	local thrustMag = moveCfg.THRUST_FORCE * legMultiplier()
	if boosting then
		thrustMag *= moveCfg.BOOST_MULTIPLIER
	end
	local targetThrust = direction * thrustMag

	-- Rampa de aceleración: suaviza el arranque/parada del empuje (menos rígido).
	local alpha = math.clamp(moveCfg.ACCEL_SMOOTHING * dt, 0, 1)
	smoothedThrust = smoothedThrust:Lerp(targetThrust, alpha)
	local thrust = smoothedThrust

	-- Drag suave (freno proporcional a la velocidad), permite conservar inercia
	local mass = rootPart.AssemblyMass
	local drag = -velocity * moveCfg.DRAG * mass

	-- Clamp de velocidad: si supera el máximo, no seguir empujando en esa dir
	if velocity.Magnitude > moveCfg.MAX_SPEED and direction.Magnitude > 0 then
		if velocity.Unit:Dot(direction) > 0 then
			thrust = Vector3.zero
		end
	end

	thrustForce.Force = thrust + drag
end

local function onStateChanged(state)
	-- Propósito: Sincronizar estado de extremidades/eliminación desde servidor.
	-- Precondiciones:
	--   1. state es una tabla con campos leftLeg/rightLeg/eliminated.
	-- Ubicación: StarterPlayerScripts/MovementController
	-- Retorna: nil
	if type(state) ~= "table" then return end
	frozenLegs.left = state[Config.Limb.LEFT_LEG] == Config.LimbState.FROZEN
	frozenLegs.right = state[Config.Limb.RIGHT_LEG] == Config.LimbState.FROZEN
	eliminated = state.eliminated == true
end

-- Conexiones
if player.Character then
	bindCharacter(player.Character)
end
player.CharacterAdded:Connect(bindCharacter)
RunService.Heartbeat:Connect(onHeartbeat)

local stateChanged = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("StateChanged")
stateChanged.OnClientEvent:Connect(onStateChanged)
