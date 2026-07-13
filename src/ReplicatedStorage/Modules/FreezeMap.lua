-- Tipo: ModuleScript
-- Ubicación: ReplicatedStorage/Modules/FreezeMap
-- Contexto: Compartido (usado como referencia por servidor; autoridad en servidor)

--[[
	FreezeMap
	Traduce el nombre de una parte del cuerpo R15 impactada al resultado de
	gameplay (congelar extremidad o eliminar). Ver RESUMEN_JUEGO §5.
	NO aplica efectos: solo mapea. La aplicación real ocurre en FreezeService.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))

local FreezeMap = {}

-- Mapa parte R15 -> resultado de impacto
local PART_TO_RESULT = {
	-- Cabeza / torso = eliminación
	["Head"] = Config.HitResult.ELIMINATE,
	["UpperTorso"] = Config.HitResult.ELIMINATE,
	["LowerTorso"] = Config.HitResult.ELIMINATE,

	-- Brazo izquierdo
	["LeftUpperArm"] = Config.HitResult.FREEZE_LEFT_ARM,
	["LeftLowerArm"] = Config.HitResult.FREEZE_LEFT_ARM,
	["LeftHand"] = Config.HitResult.FREEZE_LEFT_ARM,

	-- Brazo derecho
	["RightUpperArm"] = Config.HitResult.FREEZE_RIGHT_ARM,
	["RightLowerArm"] = Config.HitResult.FREEZE_RIGHT_ARM,
	["RightHand"] = Config.HitResult.FREEZE_RIGHT_ARM,

	-- Pierna izquierda
	["LeftUpperLeg"] = Config.HitResult.FREEZE_LEFT_LEG,
	["LeftLowerLeg"] = Config.HitResult.FREEZE_LEFT_LEG,
	["LeftFoot"] = Config.HitResult.FREEZE_LEFT_LEG,

	-- Pierna derecha
	["RightUpperLeg"] = Config.HitResult.FREEZE_RIGHT_LEG,
	["RightLowerLeg"] = Config.HitResult.FREEZE_RIGHT_LEG,
	["RightFoot"] = Config.HitResult.FREEZE_RIGHT_LEG,
}

function FreezeMap.resolve(partName)
	-- Propósito: Obtener el resultado de impacto para una parte del cuerpo.
	-- Precondiciones:
	--   1. partName es un string con el nombre de una parte R15.
	-- Ubicación: ReplicatedStorage/Modules/FreezeMap
	-- Retorna: string (Config.HitResult.*); NONE si la parte no cuenta.
	if type(partName) ~= "string" then
		return Config.HitResult.NONE
	end
	return PART_TO_RESULT[partName] or Config.HitResult.NONE
end

function FreezeMap.limbKeyFromResult(hitResult)
	-- Propósito: Obtener la clave de extremidad afectada por un resultado.
	-- Precondiciones:
	--   1. hitResult es un valor de Config.HitResult.
	-- Ubicación: ReplicatedStorage/Modules/FreezeMap
	-- Retorna: string (Config.Limb.*) o nil si no aplica a una extremidad.
	local map = {
		[Config.HitResult.FREEZE_LEFT_ARM] = Config.Limb.LEFT_ARM,
		[Config.HitResult.FREEZE_RIGHT_ARM] = Config.Limb.RIGHT_ARM,
		[Config.HitResult.FREEZE_LEFT_LEG] = Config.Limb.LEFT_LEG,
		[Config.HitResult.FREEZE_RIGHT_LEG] = Config.Limb.RIGHT_LEG,
	}
	return map[hitResult]
end

return FreezeMap
