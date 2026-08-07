-- Tipo: LocalScript
-- Ubicación: StarterPlayer/StarterPlayerScripts/HookController
-- Contexto: Cliente

--[[
	HookController
	Sistema de gancho (grappling hook) para navegar en gravedad cero.
	Al pulsar Q se lanza un gancho en la dirección de la cámara:
	- Se engancha a superficies, coberturas Y otros jugadores.
	- Cuerda elástica visual (Beam) entre el jugador y el anclaje.
	- Fuerza de atracción proporcional a la distancia (efecto elástico).
	- Si el objetivo es un jugador, el anclaje se actualiza cada frame.
	- Al soltar Q, se desengancha conservando inercia.
	- Al llegar a <2.5 studs, se suelta automáticamente.

	Movimiento principal en batalla: gancho + recoil de disparo + agarre (E).
	WASD reducido a ~1%.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local hookCfg = Config.Hook
local moveCfg = Config.Movement

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local character, rootPart, thrustForce
local hookActive = false
local anchorPoint = Vector3.zero
local anchorTarget = nil       -- Model o Instance al que estamos enganchados
local ropeBeam = nil           -- Beam visual
local ropeAttach0 = nil        -- Attachment en el jugador
local ropeAttach1 = nil        -- Attachment en el punto de anclaje
local lastHookTime = 0

player:SetAttribute("Hooking", false)

-- ===== Funciones de setup =====

local function destroyRope()
	-- Propósito: Eliminar la cuerda visual y proyectil si existen.
	-- Precondiciones: ninguna.
	-- Ubicación: StarterPlayerScripts/HookController
	-- Retorna: nil
	if ropeBeam then
		ropeBeam:Destroy()
		ropeBeam = nil
	end
	if ropeAttach1 then
		ropeAttach1:Destroy()
		ropeAttach1 = nil
	end
	if hookProjectile then
		hookProjectile:Destroy()
		hookProjectile = nil
	end
end

local function createRope(fromPos, toPos)
	-- Propósito: Crear la cuerda elástica (Beam) entre jugador y anclaje.
	-- Precondiciones:
	--   1. rootPart tiene ZB_HookAttach.
	--   2. fromPos y toPos son Vector3.
	-- Ubicación: StarterPlayerScripts/HookController
	-- Retorna: nil
	destroyRope()
	if not rootPart then return end

	ropeAttach0 = rootPart:FindFirstChild("ZB_HookAttach")
	if not ropeAttach0 then
		ropeAttach0 = Instance.new("Attachment")
		ropeAttach0.Name = "ZB_HookAttach"
		ropeAttach0.Parent = rootPart
	end

	ropeAttach1 = Instance.new("Attachment")
	ropeAttach1.Name = "ZB_HookTarget"
	ropeAttach1.WorldPosition = toPos
	ropeAttach1.Parent = workspace

	ropeBeam = Instance.new("Beam")
	ropeBeam.Name = "ZB_HookRope"
	ropeBeam.Attachment0 = ropeAttach0
	ropeBeam.Attachment1 = ropeAttach1
	ropeBeam.Color = ColorSequence.new(hookCfg.CABLE_COLOR)
	ropeBeam.Width0 = 0.35
	ropeBeam.Width1 = 0.22
	ropeBeam.Transparency = NumberSequence.new(0.1)
	ropeBeam.Texture = ""
	ropeBeam.TextureMode = Enum.TextureMode.Static
	ropeBeam.TextureLength = 1
	ropeBeam.LightEmission = 0.6
	ropeBeam.Parent = workspace
end

local hookProjectile = nil

local function spawnProjectile(fromPos, toPos)
	-- Propósito: Crear un proyectil visual que viaja al punto de impacto.
	-- Precondiciones:
	--   1. fromPos y toPos son Vector3.
	-- Ubicación: StarterPlayerScripts/HookController
	-- Retorna: nil
	if hookProjectile then
		hookProjectile:Destroy()
		hookProjectile = nil
	end

	local distance = (toPos - fromPos).Magnitude
	if distance < 0.5 then return end

	local mid = (fromPos + toPos) / 2

	local proj = Instance.new("Part")
	proj.Name = "ZB_HookProj"
	proj.Anchored = true
	proj.CanCollide = false
	proj.CanQuery = false
	proj.CastShadow = false
	proj.Material = Enum.Material.Neon
	proj.Color = hookCfg.CABLE_COLOR
	proj.Transparency = 0.2
	proj.Size = Vector3.new(0.35, 0.35, distance)
	proj.CFrame = CFrame.lookAt(fromPos, toPos) * CFrame.new(0, 0, -distance / 2)
	proj.Parent = workspace

	local tween = game:GetService("TweenService"):Create(
		proj,
		TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ Transparency = 0.7 }
	)
	tween:Play()
	game:GetService("Debris"):AddItem(proj, 0.2)

	hookProjectile = proj
end

local function bindCharacter(char)
	-- Propósito: Cachear referencias del personaje y VectorForce.
	-- Precondiciones:
	--   1. char es el modelo del personaje local.
	-- Ubicación: StarterPlayerScripts/HookController
	-- Retorna: nil
	character = char
	rootPart = char:WaitForChild("HumanoidRootPart")
	thrustForce = rootPart:FindFirstChild("ZB_ThrustForce")
	rootPart.ChildAdded:Connect(function(child)
		if child.Name == "ZB_ThrustForce" then
			thrustForce = child
		end
	end)
end

-- ===== Raycast y enganche =====

local function raycastHook()
	-- Propósito: Lanzar un raycast desde la cámara a través de la mira
	--            (mismo offset que ShootingController usa para disparar).
	--            Se engancha a todo menos al propio personaje.
	-- Precondiciones:
	--   1. camera y character válidos.
	-- Ubicación: StarterPlayerScripts/HookController
	-- Retorna: (Vector3 hitPos, Instance hitPart) o (nil, nil)
	if not camera or not character then return nil, nil end

	local viewport = camera.ViewportSize
	local screenX = viewport.X / 2 + Config.Weapon.CROSSHAIR_OFFSET_X
	local screenY = viewport.Y / 2 + Config.Weapon.CROSSHAIR_OFFSET_Y
	local ray = camera:ViewportPointToRay(screenX, screenY)
	local origin = ray.Origin
	local direction = ray.Direction.Unit

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { character }

	local hit = workspace:Raycast(origin, direction * hookCfg.MAX_RANGE, params)
	if hit then
		return hit.Position, hit.Instance
	end
	return nil, nil
end

local function findCharacterModel(hitPart)
	-- Propósito: Si la parte impactada pertenece a un personaje (Humanoid),
	--            devolver el Model. Si no, devolver nil.
	-- Precondiciones:
	--   1. hitPart es una BasePart.
	-- Ubicación: StarterPlayerScripts/HookController
	-- Retorna: Model o nil
	local model = hitPart
	while model do
		if model:IsA("Model") and model:FindFirstChildOfClass("Humanoid") then
			return model
		end
		model = model.Parent
	end
	return nil
end

local function getAnchorPosition()
	-- Propósito: Obtener la posición actual del anclaje. Si estábamos
	--            enganchados a un personaje, seguir su HumanoidRootPart.
	-- Precondiciones: ninguna.
	-- Ubicación: StarterPlayerScripts/HookController
	-- Retorna: Vector3
	if anchorTarget and anchorTarget.Parent then
		local targetRoot = anchorTarget:FindFirstChild("HumanoidRootPart")
		if targetRoot then
			return targetRoot.Position
		end
	end
	return anchorPoint
end

local function fireHook()
	-- Propósito: Lanzar el gancho y engancharse al primer impacto.
	-- Precondiciones: ninguna.
	-- Ubicación: StarterPlayerScripts/HookController
	-- Retorna: boolean (true si se enganchó)
	if hookActive then return false end
	-- Evitar conflicto con el agarre (E): no enganchar si estamos agarrados.
	if player:GetAttribute("Grabbing") then return false end
	if not rootPart then
		warn("[ZB Hook] No hay rootPart, personaje no cargado")
		return false
	end
	if not thrustForce then
		warn("[ZB Hook] No hay ZB_ThrustForce - estas en modo batalla?")
		return false
	end
	if not thrustForce.Parent then
		warn("[ZB Hook] ZB_ThrustForce sin Parent")
		return false
	end

	local now = os.clock()
	if (now - lastHookTime) < hookCfg.COOLDOWN then return false end
	lastHookTime = now

	local hitPos, hitPart = raycastHook()
	if not hitPos or not hitPart then
		warn("[ZB Hook] El gancho no impacto nada en rango (" .. hookCfg.MAX_RANGE .. " studs)")
		return false
	end

	anchorPoint = hitPos
	anchorTarget = findCharacterModel(hitPart)

	hookActive = true
	player:SetAttribute("Hooking", true)

	-- Mostrar el viaje del gancho como un proyectil, y luego la cuerda.
	spawnProjectile(rootPart.Position, hitPos)
	task.wait(0.05)
	createRope(rootPart.Position, anchorPoint)

	print("[ZB Hook] Enganchado a", hitPart:GetFullName(), "distancia =", math.floor((hitPos - rootPart.Position).Magnitude))
	return true
end

local function releaseHook(keepInertia)
	-- Propósito: Soltar el gancho, conservando parte de la inercia.
	-- Precondiciones: ninguna.
	-- Ubicación: StarterPlayerScripts/HookController
	-- Retorna: nil
	if not hookActive then return end
	hookActive = false
	player:SetAttribute("Hooking", false)
	anchorTarget = nil
	destroyRope()

	if keepInertia and rootPart then
		rootPart.AssemblyLinearVelocity = rootPart.AssemblyLinearVelocity * hookCfg.DRIFT_RETENTION
	end
end

-- ===== Actualización cada frame =====

local function updateCableVisual()
	-- Propósito: Mover el attachment del anclaje para que la cuerda siga.
	-- Precondiciones: ninguna.
	-- Ubicación: StarterPlayerScripts/HookController
	-- Retorna: nil
	if not ropeAttach1 or not ropeAttach1.Parent then return end
	local pos = getAnchorPosition()
	ropeAttach1.WorldPosition = pos
end

local function updateHook(dt)
	-- Propósito: Aplicar fuerza elástica hacia el anclaje cada frame.
	-- Precondiciones: ninguna.
	-- Ubicación: StarterPlayerScripts/HookController
	-- Retorna: nil
	if not hookActive or not rootPart or not thrustForce then return end
	if not thrustForce.Parent then
		releaseHook(false)
		return
	end

	-- Actualizar anclaje si el objetivo es un jugador (se mueve).
	local targetPos = getAnchorPosition()
	local toAnchor = targetPos - rootPart.Position
	local distance = toAnchor.Magnitude

	if distance < hookCfg.BREAK_DISTANCE then
		releaseHook(true)
		return
	end

	-- Si el objetivo es un jugador que desapareció, soltar.
	if anchorTarget and not anchorTarget.Parent then
		releaseHook(true)
		return
	end

	local dir = toAnchor.Unit

	-- Fuerza elástica: más lejos = más fuerte, más cerca = más suave.
	local forceMag = hookCfg.PULL_FORCE * math.clamp(distance / 30, 0.3, 1.2)
	local pullForce = dir * forceMag

	local velocity = rootPart.AssemblyLinearVelocity
	local mass = rootPart.AssemblyMass
	local drag = -velocity * moveCfg.DRAG * 1.8 * mass

	-- Limitar velocidad máxima de tiro.
	if velocity.Magnitude > hookCfg.MAX_PULL_SPEED then
		local velDir = velocity.Unit
		if velDir:Dot(dir) > 0 then
			thrustForce.Force = drag
			updateCableVisual()
			return
		end
	end

	thrustForce.Force = pullForce + drag
	updateCableVisual()
end

-- ===== Input =====

local function onInputBegan(input, gameProcessed)
	-- Propósito: Pulsar Q para lanzar el gancho.
	-- Precondiciones: ninguna.
	-- Ubicación: StarterPlayerScripts/HookController
	-- Retorna: nil
	if gameProcessed then return end
	if input.KeyCode == hookCfg.KEY then
		fireHook()
	end
end

local function onInputEnded(input)
	-- Propósito: Soltar Q para soltar el gancho.
	-- Precondiciones: ninguna.
	-- Ubicación: StarterPlayerScripts/HookController
	-- Retorna: nil
	if input.KeyCode == hookCfg.KEY then
		releaseHook(true)
	end
end

-- Conexiones
if player.Character then
	bindCharacter(player.Character)
end
player.CharacterAdded:Connect(bindCharacter)

UserInputService.InputBegan:Connect(onInputBegan)
UserInputService.InputEnded:Connect(onInputEnded)
RunService.Heartbeat:Connect(updateHook)
