-- Tipo: LocalScript
-- Ubicación: StarterPlayer/StarterPlayerScripts/GrabController
-- Contexto: Cliente

--[[
	GrabController
	Mecánica de "cubrirse / agarrarse" (grab & launch) estilo Ender's Game.
	Crea un ProximityPrompt (tecla E) en cada objeto con el atributo "cubrirce".
	Al mantener E el jugador se pega a la superficie del objeto con un lerp
	suave (sin temblor), reproduce la pose (Config.Grab.POSE_ANIM_ID), puede
	mirar con la cámara, y al soltar E se impulsa hacia donde mira.

	Estabilidad: en lugar de un AlignPosition (que pelea contra la colisión y
	tiembla), se ancla el HumanoidRootPart y se posiciona por CFrame cada frame,
	siguiendo al objeto si éste se mueve. Movimiento client-owned; expone el
	atributo "Grabbing".
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local grabCfg = Config.Grab

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local ROOT_ATTACH_NAME = "ZB_ThrustAttachment"
local PROMPT_NAME = "ZB_GrabPrompt"

local character, humanoid, rootPart
local poseTrack
local grabbing = false
local currentPart          -- objeto al que estamos aferrados
local grabRelCFrame        -- CFrame objetivo relativo al objeto
local grabStartCFrame      -- CFrame del root al iniciar (para el lerp)
local attachAlpha = 0      -- progreso del lerp de pegado (0..1)
local wasAnchored = false  -- estado previo de Anchored del root

player:SetAttribute("Grabbing", false)

local function log(...)
	-- Propósito: Imprimir logs de depuración si Config.Grab.DEBUG está activo.
	-- Precondiciones: ninguna.
	-- Ubicación: StarterPlayerScripts/GrabController
	-- Retorna: nil
	if grabCfg.DEBUG then
		print("[ZB Grab]", ...)
	end
end

local function bindCharacter(char)
	-- Propósito: Cachear referencias del personaje y cargar la pose de agarre.
	-- Precondiciones:
	--   1. char es el modelo del personaje local.
	-- Ubicación: StarterPlayerScripts/GrabController
	-- Retorna: nil
	character = char
	humanoid = char:WaitForChild("Humanoid")
	rootPart = char:WaitForChild("HumanoidRootPart")

	grabbing = false
	currentPart = nil
	attachAlpha = 0
	player:SetAttribute("Grabbing", false)

	local animator = humanoid:FindFirstChildOfClass("Animator")
	if not animator then
		animator = Instance.new("Animator")
		animator.Parent = humanoid
	end
	local poseAnim = Instance.new("Animation")
	poseAnim.AnimationId = grabCfg.POSE_ANIM_ID
	poseTrack = animator:LoadAnimation(poseAnim)
	poseTrack.Looped = true
	poseTrack.Priority = Enum.AnimationPriority.Action4
	log("Personaje enlazado:", char.Name)
end

local function isGrabbable(inst)
	-- Propósito: Saber si una parte tiene el atributo agarrable (o su Model).
	-- Precondiciones:
	--   1. inst es un Instance.
	-- Ubicación: StarterPlayerScripts/GrabController
	-- Retorna: boolean
	if not inst:IsA("BasePart") then return false end
	if inst:GetAttribute(grabCfg.ATTRIBUTE) then return true end
	local model = inst:FindFirstAncestorWhichIsA("Model")
	while model do
		if model:GetAttribute(grabCfg.ATTRIBUTE) then return true end
		model = model:FindFirstAncestorWhichIsA("Model")
	end
	return false
end

local function computeHoldCFrame(part)
	-- Propósito: CFrame de sujeción: sobre la superficie más cercana, mirando
	--            hacia el objeto (la espalda queda contra la cobertura).
	-- Precondiciones:
	--   1. part es una BasePart; rootPart válido.
	-- Ubicación: StarterPlayerScripts/GrabController
	-- Retorna: CFrame objetivo en espacio del mundo.
	local worldPos = rootPart.Position
	local lp = part.CFrame:PointToObjectSpace(worldPos)
	local half = part.Size / 2
	local clamped = Vector3.new(
		math.clamp(lp.X, -half.X, half.X),
		math.clamp(lp.Y, -half.Y, half.Y),
		math.clamp(lp.Z, -half.Z, half.Z)
	)
	local surface = part.CFrame:PointToWorldSpace(clamped)
	local normal = worldPos - surface
	if normal.Magnitude < 0.05 then
		normal = Vector3.new(0, 1, 0)
	else
		normal = normal.Unit
	end
	local holdPos = surface + normal * grabCfg.HOLD_OFFSET
	-- Mirar hacia la cobertura (de frente: el pecho queda contra el objeto).
	return CFrame.lookAt(holdPos, holdPos - normal)
end

local function startGrab(part)
	-- Propósito: Iniciar el agarre: anclar el root y preparar el lerp de pegado.
	-- Precondiciones:
	--   1. part es una BasePart agarrable; rootPart válido.
	-- Ubicación: StarterPlayerScripts/GrabController
	-- Retorna: nil
	if grabbing or not rootPart then
		log("startGrab ignorado (grabbing=", grabbing, "rootPart=", rootPart ~= nil, ")")
		return
	end

	local target = computeHoldCFrame(part)
	currentPart = part
	grabRelCFrame = part.CFrame:ToObjectSpace(target)  -- objetivo relativo (sigue al objeto)
	grabStartCFrame = rootPart.CFrame
	attachAlpha = 0

	-- Anclar para eliminar jitter físico; guardar velocidad para debug.
	wasAnchored = rootPart.Anchored
	rootPart.AssemblyLinearVelocity = Vector3.zero
	rootPart.Anchored = true

	grabbing = true
	player:SetAttribute("Grabbing", true)

	if poseTrack then
		poseTrack:Play(grabCfg.POSE_FADE)
	end
	log("startGrab OK en", part:GetFullName(), "distancia=", math.floor((target.Position - grabStartCFrame.Position).Magnitude))
end

local function releaseGrab()
	-- Propósito: Soltar el agarre, desanclar e impulsar hacia la cámara.
	-- Precondiciones: ninguna.
	-- Ubicación: StarterPlayerScripts/GrabController
	-- Retorna: nil
	if not grabbing then return end
	grabbing = false
	player:SetAttribute("Grabbing", false)

	if rootPart then
		rootPart.Anchored = wasAnchored
		local dir = camera.CFrame.LookVector + Vector3.new(0, grabCfg.LAUNCH_UP_BIAS, 0)
		if dir.Magnitude > 0.001 then dir = dir.Unit end
		local launchVel = dir * grabCfg.LAUNCH_SPEED
		rootPart.AssemblyLinearVelocity = launchVel
		log("releaseGrab -> impulso", string.format("(%.1f, %.1f, %.1f)", launchVel.X, launchVel.Y, launchVel.Z))
	end

	currentPart = nil
	if poseTrack then poseTrack:Stop(grabCfg.POSE_FADE) end
end

local function onGrabStep(dt)
	-- Propósito: Cada frame, mover el root hacia el punto de sujeción con lerp
	--            suave y luego mantenerlo pegado (siguiendo al objeto).
	-- Precondiciones: ninguna.
	-- Ubicación: StarterPlayerScripts/GrabController
	-- Retorna: nil
	if not grabbing or not rootPart or not currentPart or not currentPart.Parent then
		-- El objeto desapareció mientras agarrábamos: soltar de forma segura.
		if grabbing and (not currentPart or not currentPart.Parent) then
			log("Objeto de agarre perdido, soltando")
			releaseGrab()
		end
		return
	end

	local target = currentPart.CFrame * grabRelCFrame
	if attachAlpha < 1 then
		attachAlpha = math.min(1, attachAlpha + dt / math.max(grabCfg.ATTACH_TIME, 0.01))
		local eased = 1 - (1 - attachAlpha) * (1 - attachAlpha)  -- easeOutQuad
		rootPart.CFrame = grabStartCFrame:Lerp(target, eased)
	else
		rootPart.CFrame = target
	end
end

local function ensurePrompt(part)
	-- Propósito: Crear el ProximityPrompt en un part agarrable (una sola vez).
	-- Precondiciones:
	--   1. part es una BasePart agarrable.
	-- Ubicación: StarterPlayerScripts/GrabController
	-- Retorna: nil
	if part:FindFirstChild(PROMPT_NAME) then return end

	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = PROMPT_NAME
	prompt.ActionText = grabCfg.ACTION_TEXT
	prompt.ObjectText = grabCfg.OBJECT_TEXT
	prompt.KeyboardKeyCode = grabCfg.KEY
	prompt.HoldDuration = grabCfg.HOLD_DURATION
	prompt.MaxActivationDistance = grabCfg.MAX_ACTIVATION_DISTANCE
	prompt.RequiresLineOfSight = false
	prompt.Parent = part

	prompt.Triggered:Connect(function()
		log("Prompt activado en", part.Name)
		startGrab(part)
	end)
	prompt.PromptButtonHoldEnded:Connect(function()
		releaseGrab()
	end)
	log("Prompt creado en", part:GetFullName())
end

local function scanGrabbables()
	-- Propósito: Crear prompts en todos los parts agarrables existentes.
	-- Precondiciones: ninguna.
	-- Ubicación: StarterPlayerScripts/GrabController
	-- Retorna: nil
	local count = 0
	for _, inst in ipairs(workspace:GetDescendants()) do
		if isGrabbable(inst) then
			ensurePrompt(inst)
			count += 1
		end
	end
	log("scanGrabbables: objetos agarrables encontrados =", count)
end

local function onInputEnded(input)
	-- Propósito: Al soltar E, liberar el agarre e impulsarse (respaldo del
	--            PromptButtonHoldEnded para teclado).
	-- Precondiciones: ninguna.
	-- Ubicación: StarterPlayerScripts/GrabController
	-- Retorna: nil
	if input.KeyCode == grabCfg.KEY and grabbing then
		releaseGrab()
	end
end

-- Conexiones
if player.Character then
	bindCharacter(player.Character)
end
player.CharacterAdded:Connect(bindCharacter)

scanGrabbables()
workspace.DescendantAdded:Connect(function(inst)
	if isGrabbable(inst) then
		ensurePrompt(inst)
	end
end)

RunService.Heartbeat:Connect(onGrabStep)
UserInputService.InputEnded:Connect(onInputEnded)
