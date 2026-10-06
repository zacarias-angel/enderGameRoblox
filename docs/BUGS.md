# ZERO BREACH — Bugs, correcciones y regresiones

Consolidado: 2026-10-02. Leer [DISENO](DISENO.md) para comportamiento vigente y
[CHECKLIST](CHECKLIST.md) para aceptación. **Reproducir antes de corregir** y
buscar el primer error de Output, no el último warning.

## 1. Seguimiento abierto

| ID | Prioridad | Estado / siguiente acción |
|---|---|---|
| B01 | Alta | Carga lenta Lobby/Match: optimizaciones documentadas, faltan tiempos reales publicados |
| B02 | Alta | Cámara al salir: orientación/andar corregidos; giro manual con mouse aún sin validar |
| B03 | Alta | Ragdoll/cobertura/X/colores VS de 2026-09-30: prueba publicada multicuenta pendiente |
| B04 | Alta | Recarga y cosméticos: validar persistencia por reconexión y teleport, no solo memoria |
| B05 | Media | Feedback víctima 3 s y latencia gancho: repetir con dos clientes tras últimos cambios |
| B06 | Media | Assets/animaciones fallidos en Studio: validar permisos/carga en Roblox Player |
| B07 | Media | Halo y shake reforzados en ambos Places el 02/10; arranque/overlay comprobados, sensación de combate pendiente |
| B08 | Resuelto | Ambos Places abiertos; bloqueo inicial `Place is not open` resuelto |
| B09 | Límite de QA | MCP rechaza FireClient de StateChanged e inserción del fixture por Capabilities; prueba de daño automática no ejecutada |
| B10 | Alta | Corregido en Studio: UI estirada y manual duplicado; tema nativo, layout vertical y manual único en ambos Places. Validación Player/touch pendiente |

La estabilización base de Libre/VS fue validada en producción el 2026-09-14.
Las verificaciones locales posteriores no cierran automáticamente estos pendientes.

## 2. Registro de causas y correcciones

### UI estirada, recortes y manual duplicado — 2026-10-06

**Revisión posterior solicitada por el usuario:** editar IDs en un ModuleScript
no cumplía el flujo esperado de diseño visual. Se migró el arte a ImageLabels y
Frames reales en ReplicatedStorage.UIAssets, y el manual a una plantilla completa
en StarterGui en ambos Places. Sus textos y esquinas ya no se reconstruyen al
arrancar. Guía actualizada para editar Properties, no código.

- **Reproducido:** marcos del atlas deformados al rellenar paneles de otra
  proporción; la corrección antigua de coordenadas 2/3 no resolvía el escalado.
- **Corrección:** retirar el atlas de `UITheme`; usar paneles nativos y dibujos
  de trazos proporcionales. `UIAssets` permite PNG individuales completos con Fit.
- La mochila en vertical reducía el escritorio hasta hacerlo diminuto: composición
  370×650 de una columna. Manual/actividades también cambian de composición al rotar.
- En Match, el resize original del dashboard podía sobrescribir el UIScale del
  tema después de rotar: ejecutar el layout del tema con `task.defer`. Reproducido
  con viewport 401×778 y escala 0.39255; tras corregir, escala 1 y panel 370×650.
- Calendario y ayuda podían quedar sobre la mochila: ocultar accesos con modal abierto.
- Lobby tenía dos `ZB_Intro`: fallback creado antes de la copia de StarterGui.
  Esperar esa copia cuando hay plantilla y hacer el manual persistente al respawn.
- El atlas anterior se conserva en disco; no debe reactivarse para sustituir una
  sola imagen. Procedimiento operativo en [UI_ASSETS.md](UI_ASSETS.md).

### Spawn único, compañeros superpuestos y restos de energía — 2026-10-02

- LIBRE aparecía siempre en SpawnAzul. Se añadieron ocho puntos y selección por
  espacio libre, distancia/exposición y uso reciente, con confirmación local de CFrame.
- Una consulta de bounding boxes marcaba todos los puntos como ocupados por la
  malla hueca de la arena y hangar. GetPartsInPart evita ese falso positivo.
- VS colocaba a todos los miembros de un equipo en la misma posición; se añadieron
  slots de 8 studs. Un slot rojo tocaba geometría: ambos marcadores se recolocaron
  hacia el interior. Verificados cuatro espacios corporales libres por equipo.
- Añadidas barreras frontales y alas laterales; raycast de un spawn al otro
  queda bloqueado, sin encerrar las rutas laterales de salida.
- El agotamiento podía dejar una fracción insuficiente de energía en gancho/arma;
  ahora el drenaje fallido deja cero y los avisos detectan vacío/listo sin repetirse.
- Un callback antiguo de eliminación de Libre podía actuar después de salir y
  reentrar. Se invalida mediante token; syncFreeMode no reactiva combate durante
  la eliminación. El escudo replica un plazo sincronizado para su contador visual.
- La cámara de batalla propia necesita que CombatFeedback admita Scriptable;
  excepción limitada a ZB_BattleCamera, manteniendo restauración al Lobby.

QA local: spawn distinto, reset y protección correctos; salida X limpia cámara,
mouse y contador. Falta validar escenarios multicuenta y versión publicada.

### Atlas desalineado y UI pequeña en teléfono — 2026-10-02

**Síntoma:** marcos mostraban varias piezas del atlas; iconos incorrectos. En
teléfono el simple escalado del panel de escritorio volvía el texto minúsculo.

**Corrección:** coordenadas de recorte multiplicadas por 2/3; comparación visual
confirmó piezas correctas. Manual de dos columnas, dashboard compacto con scroll
y actividades en columnas para viewport bajo. Ajustar prioridad de actividades
para que la mochila no aparezca encima. Corregir ZIndexBehavior del manual para
que su marco se vea; backdrop ahora consume input y el cierre no destruye el manual.

**Verificado:** capturas desktop y simulador iPhone 17 Pro horizontal, UI de
ambos Places y arranque sin errores. Pendientes touch real, portrait y permisos
del asset publicado.

### Saldo Match y countdown del HUD — 2026-10-02

- HUD mostraba 0 monedas aunque mochila mostraba 500 porque no leía InventoryCoins.
  Añadido fallback en ambos Places; prueba local Match muestra 500 correctamente.
- HUD reinterpretaba cualquier countdown de participante como ACTIVE. La
  conversión ahora es exclusiva de LIBRE, evitando mensaje de ronda activa
  mientras el HUD VS muestra la cuenta regresiva.
- DailyActivities referenciaba refresh antes de su declaración local en callback
  de recuperación de cobro. Declaración adelantada y asignación posterior.

**Nota sobre B09:** las llamadas directas del MCP a FireClient siguen restringidas;
esta sesión pudo verificar snapshots mediante un Script temporal normal de
Studio, retirado al terminar. No modifica el alcance de las pruebas publicadas.

### Migración a Places: gravedad, movimiento y bloques (agosto–septiembre)

**Síntomas:** carga lenta de ambos Places, Lobby sin gravedad normal, Match sin
0g/movimiento/gancho, coberturas desarmadas y mezcla de servicios.

**Causas confirmadas:** GameModeService iniciaba en LOBBY y sobrescribía gravedad
del Match; 16 modelos de cobertura contenían 32 piezas sin uniones; faltaban
remotos esperados por gancho. En Libre podían coexistir LobbyGravityForce y
ThrustForce por modo del cliente desincronizado.

**Correcciones:** MatchModeBootstrap fuerza 0g/BATTLE solo en Match;
MatchArenaPhysics suelda modelos `cubrirce=true`; servicios crean contratos de
gancho. La solución inicial de cambiar gravedad global del Lobby quedó
**sustituida** el 2026-09-07: Lobby 196.2 siempre, compensación individual Libre.

**Evidencia local:** gravity=0 en Match, remotos presentes, 16 coberturas/32 welds;
ZeroGSetup crea ThrustForce/AlignOrientation con atributos de batalla. Libre
entra/sale y camina sin fuerzas residuales en pruebas posteriores.

**Diagnóstico si reaparece:** comprobar GameMode/BattleParticipant/CombatActive/
MatchId, root, Humanoid, forces y ownership. Revisar servicios incorrectos por
Place y cualquier escritor posterior de gravedad. Inspeccionar modelos completos,
WeldConstraint/Weld, Anchored, CanCollide, Massless y AssemblyRootPart.

### Segundo jugador de Libre queda en el stand (2026-09-11)

**Causa:** pedir BATTLE global de nuevo no emitía GameModeChanged; servidor movía
personaje pero cliente dueño de red conservaba posición/estado anterior.

**Corrección:** cambio dirigido FireClient y BattleTransitionController confirman
CFrame, liberan root, limpian velocidades y restauran cámara. Entrada/salida y W
verificados en Studio; revalidar simultáneamente con dos clientes publicados.

### Gancho lento, congelamiento tarda y UI pierde respuesta (2026-09-11–14)

**Causas:** HookTryConsume:InvokeServer antes de iniciar más espera 50 ms;
HookDrainTick bloqueaba Heartbeat; HUD recorría todos los descendientes por frame;
OrderedDataStore bloqueaba eliminación; DataService esperaba secuencialmente
hasta 10 s por servicio.

**Solución vigente:** inicio local inmediato, HookEnergyRequest/Result asíncronos;
HUD cachea stand; escrituras de ranking en segundo plano; DataService aplica
atributos disponibles y reintenta servicios faltantes en background. No regresar
al arreglo intermedio que solo movía InvokeServer a otra tarea.

**Evidencia:** arranque local y gancho/energía correctos; producción del 14/09
recuperó feedback/movimiento/transiciones. Faltan mediciones actuales de carga,
FPS y comparación de clientes bajo latencia.

### VS inmóvil y combate permitido fuera de ronda (2026-09-14)

**Causa:** anclar root al bloquear ronda peleaba con física client-owned; usar
BattleParticipant como único permiso confundía participación con combate activo.

**Corrección:** root no anclado para countdown; CombatActive bloquea servidor e
input/fuerzas; BattleParticipant/0g permanecen entre rondas. Movimiento/Hook y
Shooting respetan estado. No desactivar 0g entre rondas para bloquear disparo.

### Eliminación, ranking, resultado y retorno de VS (2026-09-02–30)

**Causas históricas:** Freeze llamaba API MatchService inexistente en Match;
LastAttackerUserId ausente; comprobación de equipo equivocado; teleports
individuales separaban grupo; víctima salía antes del feedback; copia física
superpuesta; fullFreeze no calculado en Match.

**Solución vigente:** MatchRuntimeService integra eliminación/ganador, Shooting
registra atacante antes de aplicar daño y acredita solo cruce a 100. Lista
PlayerUserIds/cupo exacto y mejor de tres; eliminados permanecen hasta reset;
un avatar real con CombatRagdoll. Resultado correcto por equipo y retorno
grupal reservado con reintentos. VersusHud muestra avatar/nombre 3 s y X por ronda.

Las versiones de septiembre que devolvían inmediatamente al perdedor, enviaban
solo supervivientes o dejaban un clon anclado **no son el flujo actual**.
En Libre el respawn ahora ocurre en arena después de 3 s, no en spawn del Lobby.

### Superviviente Libre pierde 0g al eliminar a otro (2026-09-02–07)

**Causa:** eliminación cambiaba modo/gravedad global del Lobby. El guardia
histórico syncFreeMode cada 0.25 s mitigó síntomas, pero no es el diseño vigente.

**Corrección actual:** estados y compensación por participante; salir/eliminar
a otro no altera física del superviviente ni salto de jugadores del Lobby.
Validar dos jugadores Libre y uno fuera al probar regresiones.

### Personaje inclinado y no gira al volver al Lobby (2026-09-30)

**Causa confirmada:** CombatFeedback reactivaba ZB_AlignOrientation cada frame
fuera de batalla y competía con Humanoid.AutoRotate.

**Corrección:** activar orientación solo en batalla sin ragdoll. GravityController
retira ThrustForce/AlignOrientation/ThrustAttachment, endereza root y limpia
velocidades; restaura caminar/saltar, AutoRotate, PlatformStand=false, cámara
Custom y mouse normal. AstronautPose restaura offsets; reintento de activación
0g verifica estado actual. ZeroGSetup recrea física al reentrar.

**Verificado:** salida X, root vertical, giro de avatar W/D ~90°, reentrada.
**Pendiente B02:** giro real de cámara con mouse; arrastre automatizado inconcluso.

### Taller bloqueado por otro jugador y cosméticos no persisten (2026-09-14)

**Causas:** compras validaban modo global; normalización descartaba puntas/cuerdas;
ranking mostraba caché histórica de ceros y no estadística conectada.

**Corrección:** validar GameMode del comprador; guardar ownedHookTips/Ropes y
selección, reparar propiedad del equipado; mezclar ranking vivo/histórico y
refrescar categoría por evento con debounce 0.2 s. FullFreeze únicamente a 100.

**Pendiente B04:** dos cuentas compran/equipan distinto y reconectan, ranking
incrementa inmediatamente y conserva total después de reconnect/teleport.

### Inventario Match vacío y cosméticos rellenan energía (2026-09-30)

**Causas:** lectura desde raíz en lugar de profile.workshop; equipar reaplicaba
perfil completo; dependencias de moneda/taller exclusivas del Lobby.

**Corrección:** leer workshop, capturar equipados al guardar sin reaplicar perfil,
reintentar solo servicios requeridos y usar InventoryCoins como saldo alternativo.
EquipmentDashboard sustituye pantallas antiguas deshabilitadas.

### Misiones no avanzan, cobro sin respuesta y monedas físicas (2026-09-02–14)

**Causas:** no registrar playMatches en nuevo flujo; monedas con colisión y conteo
`#` sobre diccionario; guardado bloqueante y botón esperando para siempre.

**Corrección:** Libre registra entrada, retorno VS deduplica por MatchId; monedas
CanCollide=false/CanTouch=true, contar pairs; feedback antes de guardado, bloqueo
de doble cobro, recuperación del botón a 5 s. Logro normalizado y notificado.

**Evidencia:** 42 monedas sin colisión/con toque; cobro de misión +40 en Studio.
Revalidar Player, misión 25 monedas, daily/logro y retorno VS una vez.

### Power-ups repiten ubicación o NO_AVAILABLE_POINTS (2026-09-07)

**Causa:** 13 de 15 referencias sin anclar caían y eran eliminadas; selector
dependía de IDs temporales. Impulso solo en servidor era lento por ownership.

**Corrección:** Punto1..15 anclados en ambos Places, referencia directa,
exclusión de ocupados/dos puntos anteriores y fallback; ocultar hasta posición
inicial. Impulso validado se comunica al cliente dueño de red. FreeFreezeScore
se limita con math.max(0, value). Verificados 15 puntos persistentes/3 spawns distintos.

### Beam se queda sin efecto en brazos o falla al agotarse

**Causas:** congelación binaria impedía más daño por extremidad; beamBlockedUntil
sin inicializar llegaba a math.max; porcentaje no replicado para todas las zonas.

**Corrección:** todos los hits a addFreezeProgress, porcentaje actualizado por
impacto, beamBlockedUntil=0, corte/overheat 0.5 s. VFX doble haz restaurado y vidrio
decorativo filtrado sin eliminar cobertura opaca.

### Bugs iniciales de agarre/UI conservados como prevención

- GrabController contenía AstronautPose y esperaba Humanoid en PlayerScripts:
  corregir ruta/código; pose pertenece a StarterCharacterScripts.
- AlignPosition de fuerza alta peleaba con colisiones y provocaba jitter:
  transición CFrame suave durante agarre; limpiar anclaje al liberar.
- Parches parciales dejaron createTipModel o refresh ausentes: leer contexto
  completo y compilar antes de Play.
- ScreenGui no sirve como GuiObject para InputBegan: conectar input al elemento
  apropiado. Controladores antiguos de tienda/mochila permanecen deshabilitados.
- Detección amplia de cualquier NPC alteraba rondas: dummy de prueba explícito
  IsMatchDummy=true; no usarlo para entregar monedas.

## 3. Procedimiento de diagnóstico

1. Registrar Place, versión/publicación, clientes, pasos, resultado esperado/real.
2. Abrir Output desde arranque y localizar primer error de scripts del juego.
3. Medir PlayerAdded, CharacterAdded, carga de perfil, UI y teleport por separado.
4. Inspeccionar estado del jugador, gravedad y fuerzas; probar movimiento sin gancho.
5. Probar gancho contra superficie válida y revisar energía/eventos/visual.
6. Inspeccionar una cobertura con uniones completas; no modificar todo Workspace.
7. Probar ambos Places aislados; después teleport publicado con grupo real.
8. Registrar qué se verificó y qué sigue pendiente; no cerrar por compilación sola.

**Mensajes de entorno:** HTTP 403/REJECT_NO_TELEPORT_DATA de Play Solo no equivalen
a fallo de producción; avisos de assets con serverplaceid=0 requieren comprobación
publicada. Mensajes Assistant y desconexiones 127.0.0.1 registrados pertenecían
al plugin MCP, no automáticamente al juego. No descartar un reporte real del
jugador por parecerse a uno de esos mensajes.
