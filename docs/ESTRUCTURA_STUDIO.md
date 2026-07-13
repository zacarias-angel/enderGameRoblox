# Estructura en Roblox Studio — ZERO BREACH

Crea esta jerarquía en Studio y pega cada script del proyecto (`src/`) en la
ubicación indicada. Sigue `ReglasRoblox.md` §1.

```
ReplicatedStorage/
├── Shared/
│   └── Config              (ModuleScript)   <- src/ReplicatedStorage/Shared/Config.lua
├── Modules/
│   └── FreezeMap           (ModuleScript)   <- src/ReplicatedStorage/Modules/FreezeMap.lua
└── RemoteEvents/           (AUTO-CREADA por el servidor al iniciar)
    ├── FireWeapon          (RemoteEvent)     <- auto-creado, no hace falta crearlo
    └── StateChanged        (RemoteEvent)     <- auto-creado, no hace falta crearlo

ServerScriptService/
├── PlayerStateService      (Script)          <- src/ServerScriptService/PlayerStateService.server.lua
├── FreezeService           (Script)          <- src/ServerScriptService/FreezeService.server.lua
└── ShootingService         (Script)          <- src/ServerScriptService/ShootingService.server.lua

StarterPlayer/
├── StarterPlayerScripts/
│   ├── MovementController   (LocalScript)    <- src/StarterPlayer/StarterPlayerScripts/MovementController.client.lua
│   ├── ShootingController   (LocalScript)    <- src/StarterPlayer/StarterPlayerScripts/ShootingController.client.lua
│   └── HudController        (LocalScript)    <- src/StarterPlayer/StarterPlayerScripts/HudController.client.lua
└── StarterCharacterScripts/
    ├── ZeroGSetup           (LocalScript)    <- src/StarterPlayer/StarterCharacterScripts/ZeroGSetup.client.lua
    ├── AstronautPose        (LocalScript)    <- src/StarterPlayer/StarterCharacterScripts/AstronautPose.client.lua
    └── WeaponSetup          (LocalScript)    <- src/StarterPlayer/StarterCharacterScripts/WeaponSetup.client.lua
```

## Pasos previos en Studio

1. **Workspace**: selecciona `Workspace`, en Propiedades pon `Gravity = 0`.
2. **Arena de prueba**: crea un `Part` grande hueco o 6 paredes formando un
   cubo. Añade unos cubos anclados flotando como coberturas.
3. **Carpetas y RemoteEvents (opcional)**: `ShootingService` y
   `PlayerStateService` **auto-crean** `ReplicatedStorage/RemoteEvents` con
   `FireWeapon` y `StateChanged` al iniciar. Solo necesitas crear a mano las
   carpetas `Shared` y `Modules` (donde van `Config` y `FreezeMap`).
4. Pega cada script en su lugar respetando el **nombre exacto** y el **tipo**.

## Orden de prueba

1. `Config` + `ZeroGSetup` + `MovementController` → deberías **volar** con
   WASD/Espacio/Ctrl y **boost** con Shift, con inercia y giro suave hacia la
   cámara + inclinación (banking).
2. Añade `AstronautPose` + `WeaponSetup` → pose flotante de astronauta y el
   blaster soldado a la mano derecha.
3. Añade `FreezeMap` + los 3 servicios + `ShootingController` → dispara: verás
   el láser desde el cañón + destello + impacto, y congelación/eliminación por
   zona sobre un dummy R15.
4. Añade `HudController` → LED, energía y mira.

> Nota: las extensiones `.client.lua` / `.server.lua` son solo convención de
> nombre para saber el contexto. En Studio, el **tipo** de instancia
> (LocalScript / Script / ModuleScript) es lo que importa.
