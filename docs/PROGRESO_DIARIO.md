# Progreso Diario — ZERO BREACH

Bitácora de avance por sesión. Entrada más reciente arriba.

---

## Sesión 7

**Objetivo:** arreglar temblor/empuje al cubrirse y suavizar el pegado.

### Problema
- Con `AlignPosition` + `MaxForce` alto, el constraint peleaba contra la
  colisión del personaje: temblor y sensación de alejarse del objeto.

### Hecho
- `GrabController` cambia de estrategia: **ancla** el HumanoidRootPart y lo
  posiciona por **CFrame con lerp suave** (easeOutQuad) hacia el punto de
  sujeción, siguiendo al objeto si se mueve. Sin jitter físico.
- Pose de agarre con crossfade (`POSE_FADE`).
- Impulso al soltar mantiene la dirección de cámara.
- **Logs de depuración** `[ZB Grab]` (Config.Grab.DEBUG = true) en: enlace de
  personaje, escaneo de agarrables, creación/activación de prompt, inicio/soltar
  de agarre y pérdida del objeto.
- `Config.Grab`: `ATTACH_TIME`, `POSE_FADE`, `HOLD_OFFSET` ajustable, `DEBUG`.

### Notas
- Si sigue el jitter, subir `ATTACH_TIME` o revisar que el objeto no tenga
  física activa (mejor `Anchored`).
- Poné `DEBUG = false` en producción.

---

## Sesión 6

**Objetivo:** arreglar el agarre y usar ProximityPrompt.

### Problema encontrado
- Error "Infinite yield on PlayerScripts:WaitForChild('Humanoid')": el script
  `GrabController` en Studio tenía pegado por error el código de `AstronautPose`
  (que usa `script.Parent` como personaje y va en StarterCharacterScripts).

### Hecho
- `GrabController` reescrito con **ProximityPrompt**: crea un prompt (tecla E)
  en cada objeto con atributo `cubrirce`, así aparece el hint al acercarte.
  Mantener E = agarrarse (pose), soltar E = impulso hacia la cámara.
- Detecta objetos nuevos en runtime (`workspace.DescendantAdded`).
- `Config.Grab`: parámetros de ProximityPrompt (distancia, textos, hold).

### Recordatorio Studio
- `GrabController` va en **StarterPlayerScripts**.
- `AstronautPose`, `ZeroGSetup`, `WeaponSetup` van en **StarterCharacterScripts**.
- Marcá coberturas con Atributo booleano `cubrirce = true`.

---

## Sesión 5

**Objetivo:** mecánica de "cubrirse / agarrarse" (grab & launch) estilo Ender.

### Hecho
- Nuevo `GrabController` (StarterPlayerScripts): manteniendo **E** cerca de un
  objeto con atributo `cubrirce`, el jugador se aferra a su superficie con una
  pose (`Config.Grab.POSE_ANIM_ID = 133886935716379`), puede mirar con la
  cámara, y al soltar E se **impulsa** hacia donde mira.
  - Anclado con `AlignPosition` a un attachment fijo en el objeto (sigue al
    objeto si se mueve).
  - Expone atributo `Grabbing` en el jugador para coordinar.
- `MovementController`: ignora el empuje mientras `Grabbing` (deja mandar al
  agarre) y mantiene la orientación con la cámara.
- `AstronautPose`: silencia el nado durante `Grabbing` y permite la pista de la
  pose de agarre (no la detiene el guardia).
- `Config.Grab`: parámetros de radio, offset, velocidad de impulso, etc.

### Uso en Studio
- Marcá coberturas con Atributo booleano `cubrirce = true`.

---

## Sesión 4

**Objetivo:** probar la animación oficial de natación como flotación en 0g.

### Hecho
- `AstronautPose` ahora soporta dos modos vía `Config.Pose.MODE`:
  - `"swim"` (por defecto): reproduce las animaciones oficiales de natación de
    Roblox (swim + swimidle) con crossfade por velocidad, vía Animator.
  - `"procedural"`: la pose por código anterior (Motor6D + ondas seno).
- Se reproducen por el `Animator` para funcionar aunque el Humanoid esté en
  estado `Physics`.

### Notas / decisiones
- Para comparar, cambiar `Config.Pose.MODE` entre "swim" y "procedural".
- Si Roblox cambia los IDs oficiales, ajustar `SWIM_ANIM_ID`/`SWIM_IDLE_ANIM_ID`
  en `AstronautPose`.

---

## Sesión 3

**Objetivo:** hacer que el sistema de disparo detecte cualquier personaje con
Humanoid (dummies), no solo jugadores.

### Hecho
- `ShootingService`: `characterFromPart` ahora devuelve el Model del personaje
  (sin exigir Player); `validateAndResolve`/`onFire` operan por personaje.
- `FreezeService`: reescrito **character-centric**. Mantiene estado por
  personaje (`charStates`) para dummies y jugadores. Si el personaje pertenece
  a un Player, además sincroniza con `PlayerStateService` (HUD/LED).
- Resultado: los dummies R15 ahora reciben congelación por extremidad y
  eliminación.

### Próximo
- Probar en Studio disparando al dummy R15.
- Fase 2: equipos, Puerta de Extracción, escudos humanos.

---

## Sesión 2

**Objetivo:** arreglar feel de movimiento, añadir arma visible y láser, y pose
de astronauta.

### Hecho
- **Flotación fluida**: `AlignOrientation` ahora sigue la cámara con
  responsiveness bajo + inclinación (banking) según velocidad; drag reducido y
  rampa de aceleración suave en `MovementController`.
- **Pose astronauta procedural** (`AstronautPose`): desactiva `Animate` y anima
  los Motor6D (hombros/caderas/cintura) con ondas seno; brazos hacia atrás al
  acelerar.
- **Blaster** (`WeaponSetup`): modelo procedural soldado a la mano derecha con
  Attachment `Muzzle`.
- **Láser visible** (`ShootingController`): beam neón desde el muzzle con fade,
  muzzle flash + luz e impacto (chispa).
- `Config` ampliado: bloques `Orientation`, `Pose` y VFX de láser en `Weapon`.

### Próximo
- Probar en Studio y ajustar valores (drag, tilt, amplitudes de pose).
- Fase 2: equipos, Puerta de Extracción, escudos humanos.

### Notas / decisiones
- Animación y arma: **procedural en código** (sin assets subidos).
- Carpetas `RemoteEvents` se auto-crean; solo crear `Shared` y `Modules`.

---

## Sesión 1

**Objetivo:** arranque del proyecto (documentación + MVP núcleo).

### Hecho
- Documentación de diseño completa:
  - `RESUMEN_JUEGO_ACTUALIZADO.md` — diseño general de ZERO BREACH.
  - `sistema_captura_y_economia.md` — Puerta de Extracción (Fase 2).
  - `UI_ASSET_SPEC.md` — HUD, LED y assets.
  - `RUTA_CHECKLIST_DESARROLLO_PETS_Y_PVP.md` — roadmap por fases.

### En curso
- MVP: movimiento 0g + disparo + congelación por zona.

### Próximo
- Guía de estructura de carpetas en Studio.
- Scripts: Config, FreezeMap, ZeroGSetup, MovementController.

### Notas / decisiones
- MVP en todos-contra-todos; equipos en Fase 2.
- Personaje R15 estándar.
- Movimiento por inercia (VectorForce), no velocidad fija.
- Controles: WASD + Espacio (subir) + Ctrl (bajar) + Shift (boost) + Click.
