-- Tipo: Script
-- Ubicacion: ServerScriptService/HoloLevitation
-- Contexto: Servidor

--[[
	HoloLevitation
	Hace que los paneles holograficos en Workspace/Hologramas
	floten suavemente hacia arriba y abajo (efecto de levitacion).
]]

local TweenService = game:GetService("TweenService")

local function setupLevitacion(part, amplitude)
	if not part:IsA("BasePart") then return end
	local amp = amplitude or 1.2
	local info = TweenInfo.new(
		2.5 + math.random() * 1.5,
		Enum.EasingStyle.Sine,
		Enum.EasingDirection.InOut,
		-1,
		true
	)
	local goal = {CFrame = part.CFrame + Vector3.new(0, amp, 0)}
	local tween = TweenService:Create(part, info, goal)
	tween:Play()
end

local hf = workspace:FindFirstChild("Hologramas")
if hf then
	for _, obj in ipairs(hf:GetChildren()) do
		setupLevitacion(obj)
	end
	hf.ChildAdded:Connect(function(child)
		task.wait(0.1)
		setupLevitacion(child)
	end)
end
