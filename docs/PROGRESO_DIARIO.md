# Progreso Diario — ZERO BREACH

Bitácora de avance por sesión. Entrada más reciente arriba.

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
