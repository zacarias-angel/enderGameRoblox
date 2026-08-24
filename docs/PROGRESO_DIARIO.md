# Progreso Diario — ZERO BREACH

Bitácora de avance por sesión. Entrada más reciente arriba.

---

## Sesion 13

**Objetivo:** cerrar el pulido del beam continuo y documentar la correccion.

### Hecho
- `ShootingService`: el porcentaje de congelamiento se replica tras cualquier
  impacto valido, incluidas extremidades.
- `ShootingController.client`: restaurado el VFX completo del beam local con haz
  exterior/interior, ondulacion, brillo y particulas de impacto.
- `ShootingService`: al agotar la estamina envia la señal de sobrecalentamiento y
  corta el beam; el cliente apaga el VFX y bloquea el disparo durante `0.5 s`.
- `ShootingService`: el rayo ignora vidrio decorativo transparente sin ignorar
  coberturas opacas.
- `Config`: consumo del beam ajustado a `30` por segundo para que la energia
  permita una rafaga continua utilizable.

### Pendiente
- Revalidar visualmente en una partida con dos jugadores el VFX y la barra de
  congelamiento sobre una extremidad y sobre el torso.

---

## Sesion 12

**Objetivo:** cerrar recompensas de combate y resultado de ronda con MVP.

### Hecho
- `MatchService`: al terminar la ronda envia `roundSummary` a cliente con ganador y resumen de participantes reales.
- `RankService`: snapshot por ronda para calcular MVP y estadisticas de esa partida.
- `RoundResultController.client`: ahora muestra MVP, eliminaciones, congelaciones y estadisticas locales de la ronda.
- Recompensas activas de combate:
  - jugar partida: `+15` monedas
  - ganar partida: `+30` monedas extra
  - congelar extremidad a un rival jugador: `+2` monedas
  - eliminar a un rival jugador: `+8` monedas
- Las recompensas no se entregan en `Partida invalida`.
- El dummy/NPC de prueba no da monedas.
- Primer logro implementado: `Cumpliste todas las misiones diarias`.
  - se desbloquea al reclamar todas las misiones del dia
  - recompensa unica: `+120` monedas
  - persistencia en `DataService`
  - toast visual en cliente con `AchievementController.client`
- Ajuste de balance del core jugable:
  - boost menos castigado (`drain 24`, regen general `18`)
  - disparo mas usable (`Blaster 24`, `Rifle 20`, `Cañon 55` de costo)
  - gancho mas sostenible (`use 18`, `drain 9`, regen `10`)
  - el gancho vuelve a mantenerse mientras `Q` siga presionada y no se corta solo al llegar al punto
- Pasada de estabilidad en Studio:
  - `ShootingService` reescrito para resolver impacto desde el muzzle hacia el punto apuntado, con debug `[ZB Shoot]` en Studio.
  - `HudController`: contador de countdown/partida ahora se recompone por tiempo local y no depende solo del ultimo evento recibido.
  - `HookController`: el gancho se corta si la tecla real `Q` deja de estar presionada aunque falle `InputEnded`.
- Cambio de sistema de disparo:
  - agregado `Config.WeaponSystem.MODE = "beam" | "pulse"`
  - modo activo actual: `beam`
  - `beam`: mantener click para disparo continuo, consumo continuo de estamina, raycast periodico en servidor y beam local/remoto
  - `pulse`: queda como backup seleccionable por config

### Nota
- El ranking historico ya quedo preparado para top 20, pero su validacion real depende de DataStore fuera de esta sesion de Studio.

---

## Sesion 11

**Objetivo:** cerrar regresiones del fin de ronda despues de la ultima actualizacion.

### Hecho
- `MatchService`: cuando ya solo queda un equipo con vida, la ronda termina de inmediato y anuncia ganador sin esperar `FINALIZE_TIME`.
- `MatchService`: si se agota el tiempo sin ventaja, la ronda ahora cierra como empate en vez de quedar activa indefinidamente.
- `MatchService`: el dummy de prueba ya no debe detectarse por "cualquier NPC"; ahora solo cuenta un `Model` marcado con `IsMatchDummy = true`.
- `ESTRUCTURA_STUDIO.md`: agregado el requisito del atributo `IsMatchDummy` para configurar el dummy correctamente en Studio.

### Pendiente
- Traer y comparar los scripts reales desde Roblox Studio para confirmar que esta correccion tambien quede aplicada en la experiencia publicada.
- Revalidar en Studio el flujo completo: ganador, panel de resultado, retorno al lobby y reset de estados al terminar la ronda.

---

## Sesión 10

**Objetivo:** persistencia real, recompensa diaria, misiones, gancho con energia propia y cierre del backup de codigo.

### Hecho
- `DataService.server`: perfil base, carga/guardado, autosave, `BindToClose` y modo seguro para Studio sin API Services.
- Persistencia conectada a monedas, taller, preferencias, estamina, energia del gancho y estadisticas de ranking.
- `DailyRewardService.server` + `DailyRewardController.client`: recompensa diaria con streak basica y UI en lobby.
- `MissionService.server` + `MissionController.client`: misiones diarias simples para jugar partida, juntar monedas y reclamar daily.
- `RoundResultController.client`: panel de resultado de ronda.
- Energia del gancho separada de la estamina de disparo:
  - `HookEnergyService.server`
  - barra propia en HUD
  - gasto al lanzar
  - gasto continuo mientras arrastra
  - regeneracion mas lenta
- Cosmeticos del gancho:
  - punta 3D reemplazable
  - cuerda configurable por color/grosor
  - compra/equipado en taller
- `WorkshopController.client` rehacido a panel compacto por pestañas: `Base`, `Armas`, `Laser`, `Gancho`.
- `REEMPLAZOS_STUDIO.md`: guia para reconstruir en Studio assets no versionados por git.
- `MatchService`: Play en Studio vuelve a iniciar en lobby; no entra automaticamente a arena.

### Bugs encontrados y correcciones
- `HookController.client`: error por parche parcial (`createTipModel` ausente). Se reescribio limpio.
- `WorkshopController.client`: errores de `refresh()` nil y cierre con `ScreenGui.InputBegan`. Se rehizo el flujo.
- `MatchService`: deteccion de dummy demasiado amplia. Ahora solo debe contar un NPC marcado explicitamente con `IsMatchDummy = true`.
- `FreezeService` / `GravityController`: se reforzo el reset para volver al lobby con color/material/salto normal.

### Pendiente de revalidar en Studio
- Confirmar en una partida completa que:
  - al perder aparece ganador sin esperar al timer,
  - al volver al lobby no queda ningun estado residual de congelado,
  - el ranking persiste y no depende solo de jugadores conectados.

---

## Sesión 9

**Objetivo:** sesión de diseño (sin código). Evaluar "empujar el cuerpo",
mira ADS y gravedad 0 por modos.

### Decisiones

**Escudo humano (agarre de cuerpos):**
- **NO cancelar el giro** del cuerpo al agarrarlo: que siga girando es parte
  del feel/caos de 0g. Si resulta divertido, se queda (regla del proyecto).
- **SÍ anclaje fijo a la espalda del torso**: al agarrar un cuerpo eliminado,
  el punto de sujeción deja de ser "superficie más cercana"
  (`computeHoldCFrame`) y pasa a ser siempre la **espalda del torso**, para
  que el cuerpo quede entre el portador y el frente (cobertura real).
- **Carry completo (diseño A, llevar el cuerpo por delante):** queda en
  evaluación. Riesgos identificados: network ownership del cuerpo, colisiones
  con el mapa (collision groups), lock de portador en servidor (robo de
  cuerpo), soltar con inercia si eliminan al portador, validación
  anti-exploit de mover Models ajenos. Primero se prueba el anclaje a la
  espalda; si con eso ya es divertido, quizá el carry no haga falta.

**Mira / ADS:**
- Apuntar = **mantener click derecho**: zoom de FOV (lerp), mira en pantalla,
  sensibilidad reducida.
- Pendiente de definir: hipfire con dispersión vs. solo disparo en ADS;
  subir `Responsiveness` de orientación durante ADS; conflicto con la
  rotación de cámara default de Roblox (click derecho).

**Gravedad 0 por modos (no por zonas):**
- La gravedad 0 es del **modo batalla / modo duelo** (la arena). El lobby
  tiene gravedad normal.
- **Interruptor del lobby (opción B — global):** un switch en el lobby pone
  `Workspace.Gravity = 0` **para todos** como evento caótico/divertido. No
  afecta al modo batalla porque ese modo **ya está en 0g**.
- Nota técnica abierta: `Workspace.Gravity` es global; hay que definir cómo
  convive el lobby con gravedad normal y la arena en 0g (modo 0g por
  personaje al entrar a la arena vs. places separados). Se decide cuando se
  implemente el ciclo de modos.

### Próxima sesión (planificado)
- [ ] Implementar **anclaje a la espalda del torso** en `GrabController`
  (cuerpos-escudo; sin cancelar el giro).
- [ ] Prototipo de **ADS con click derecho** (FOV + mira + sensibilidad).
- [ ] Definir estructura lobby / modo batalla para la gravedad por modos +
  interruptor caótico del lobby.
- [ ] Pendientes que siguen de Sesión 8: limpiar `cubrirce` al
  revivir/reset, feedback en HUD del portador, `Config.Grab.DEBUG = false`,
  verificar reducción de empuje por piernas congeladas.

---

## Sesión 8

**Objetivo:** convertir a los cuerpos eliminados en escudos humanos (cobertura móvil).

### Hecho
- `FreezeService.eliminate`: al neutralizar a un personaje (jugador o dummy) le
  asigna el atributo `cubrirce = true`, marcándolo como agarrable.
- `GrabController`: nuevo watcher de personajes (`watchCharacter` /
  `scanCharacters`) que detecta cuando un Model con Humanoid queda marcado
  —incluso si el atributo se pone en runtime al morir— y crea **un solo**
  ProximityPrompt en su torso (`ensureShieldPrompt`). No permite aferrarse a
  uno mismo.
- `Config.Grab`: textos `SHIELD_ACTION_TEXT` ("Sujetar") / `SHIELD_OBJECT_TEXT`
  ("Escudo") para el prompt del cuerpo eliminado.

### Notas
- Reutiliza la mecánica de agarre existente: un vivo se aferra al cuerpo y lo
  usa de cobertura. **Empujar** el cuerpo (escudo activo por delante) es una
  mejora pendiente para una sesión futura.
- Probado con dummy R15: congelar extremidades / eliminar por torso-cabeza ya
  funciona; el prompt de escudo aparece sobre el cuerpo flotante.

### Próxima sesión (planificado)
- [ ] **Empujar el cuerpo (escudo activo):** que el vivo lleve el cuerpo
  congelado por delante y pueda desplazarlo, en vez de solo aferrarse.
  Definir si el empuje es cliente (feel) con validación de estado en servidor.
- [ ] **Limpiar el atributo al revivir/reset:** cuando el personaje respawnee o
  se reinicie la ronda, quitar `cubrirce` para que deje de ser agarrable.
- [ ] **Feedback en HUD del portador:** indicar cuándo estás sujetando un
  escudo (icono/estado).
- [ ] **Poner `Config.Grab.DEBUG = false`** antes de cerrar el pulido.
- [ ] Cerrar checklist MVP: verificar en Studio "reducción de empuje por piernas
  congeladas" (`MovementController` + `LEG_*_FROZEN_MULT`).
- [ ] Tras cerrar MVP, arrancar **Fase 2**: sistema de equipos Azul/Rojo
  (prerequisito de Puerta de Extracción y escudos por equipo).

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
