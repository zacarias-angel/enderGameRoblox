# Reemplazos En Studio

## Gancho

### Punta 3D del gancho
- Carpeta: `ReplicatedStorage/HookCosmeticAssets/HookTips`
- Cada punta debe ser un `Model`.
- El `Model` debe tener `PrimaryPart` asignado.
- Todas las partes internas deben ser `BasePart` o `MeshPart`.
- Recomendado:
  - largo aproximado: `0.9` a `1.2` studs
  - ancho/alto: `0.3` a `0.45` studs
- El sistema la clona y la usa de 2 maneras:
  - proyectil visual al salir
  - modelo persistente en la punta del cable cuando el gancho queda enganchado
- IDs actuales esperados por config:
  - `default`
  - `spike`
  - `heavy`

### Qué reemplazar para usar una punta propia
1. Crear o importar tu `Model` en `ReplicatedStorage/HookCosmeticAssets/HookTips`.
2. Ponerle exactamente el nombre del `id` configurado.
3. Asignarle `PrimaryPart`.
4. Verificar que se vea bien orientado mirando hacia adelante en su eje Z.

### Cuerda del gancho
- La cuerda no usa modelo 3D.
- La cuerda se define por config en `Config.HookRopeCosmetics`.
- Cada entrada usa:
  - `id`
  - `name`
  - `color`
  - `width0`
  - `width1`

## Taller

### Prompt del taller
- El objeto físico del taller debe ser un `BasePart`.
- Debe tener atributo:
  - `isTaller = true`

## UI 2D

### Taller 2D
- Script actual: `StarterPlayer/StarterPlayerScripts/WorkshopController.client`
- La UI se construye por código.
- Si querés reemplazar el diseño completo tenés 2 caminos:

#### Opción 1: seguir con UI por código
- Cambiar directamente `WorkshopController.client`.
- Mantener estos elementos de comportamiento:
  - botón cerrar
  - tabs/pestañas
  - llamadas a `WorkshopBuy`
  - cierre automático fuera de lobby

#### Opción 2: usar tu propio diseño 2D
- Crear una `ScreenGui` propia con Frames, botones e imágenes.
- Podés hacerla en Studio o importarla como layout manual.
- El script debe seguir resolviendo estas acciones:
  - `WorkshopBuy("stamina")`
  - `WorkshopBuy("hookEnergy")`
  - `WorkshopBuy("hookRegen")`
  - `WorkshopBuy("weapon", weaponId)`
  - `WorkshopBuy("color", colorId)`
  - `WorkshopBuy("hookTip", tipId)`
  - `WorkshopBuy("hookRope", ropeId)`

### Assets 2D propios
- Si querés reemplazar iconos, fondos o botones por arte 2D propio:
  - usar `ImageLabel` o `ImageButton`
  - subir imágenes a Roblox y usar `rbxassetid://...`
- Recomendado documentar por cada asset:
  - nombre lógico
  - asset id
  - tamaño base
  - dónde se usa

## Reglas útiles
- Punta del gancho: `Model` con `PrimaryPart`.
- Partes del modelo: sin colisión y tamaño compacto.
- Cuerda: se personaliza por config, no por modelo.
- UI 2D: se puede cambiar completa, pero el script debe seguir disparando los remotes correctos.
