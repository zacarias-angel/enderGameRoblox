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
| B11 | Alta | Renovación diaria en sesión abierta: reproducida, corregida y verificada en Studio el 09/10. Falta validar medianoche/reconexión en Player; cobro persistente y ranking siguen abiertos |
| B12 | QA publicada parcial | Usuario confirma arma/apuntado/Beam y observador remoto en Libre/VS; rigs alternativos siguen pendientes |
| B13 | Alta / corregido Studio | Cancelación sin impulso, epoch de cuerpo, limpieza de etiqueta y salida comprobados; repetir con dos jugadores publicados |
| B14 | Media / corregido Studio | Running silenciado en 0g y restaurado en Lobby; repetir escucha real/primera persona publicada |
| B15 | Alta / corregido Studio | Origen público, anulación grupal, reintento y fallback común comprobados con transporte simulado; teleport real con tercero pendiente |
| B16 | Alta / corregido Studio | VICTORIAS VS, encuentro completo deduplicado y congelados Libre; API/guardado en memoria comprobados, persistencia publicada pendiente |

La estabilización base de Libre/VS fue validada en producción el 2026-09-14.
Las verificaciones locales posteriores no cierran automáticamente estos pendientes.

## 2. Registro de causas y correcciones

### Correcciones tras el reporte publicado — B13 a B16, 2026-10-09

**Implementadas y comprobadas en Studio; no publicadas desde esta sesión.**
Respaldo por Place: `ServerStorage.ZB_ProductionFixBackup_20261009`.

#### B13 — cuerpo restaurado y etiqueta de agarre

- Reproducido con funciones anteriores exactas: quitar `cubrirce` dejaba agarre
  activo. La cancelación ahora se diferencia de soltar voluntariamente: no impulsa
  portador ni objetivo, libera anclaje, detiene pose y limpia referencias/listeners.
- FreezeService invalida `cubrirce`, incrementa `ZB_GrabEpoch` y comunica
  `CancelGrabForTarget` antes de reset/restauración; CharacterRemoving también invalida.
- Cliente verifica vigencia/epoch antes de seguir al objetivo, incluidos Model de
  arma/accesorio anidados. Un prompt de escudo por avatar; se retira al restaurar.
  Fuera de combate/countdown/menú se deshabilitan prompts y se cancela la sujeción.
- QA: invalidación, epoch, salida sin impulso, root desanclado, eliminación de
  etiqueta y caso de pieza anidada. Las señales locales diferidas se comprobaron
  tras su ejecución; los errores iniciales del fixture por comprobar antes de
  ese momento no se atribuyen a un fallo de producción.

#### B14 — pasos al flotar

- Nuevo LocalScript `ZeroGFootsteps` en ambos Places: administra únicamente
  sonidos/AudioPlayers llamados Running en avatares observables, por eventos.
  Mute por BattleParticipant/GameMode de cada jugador o gravedad global cero.
  Conserva el volumen previo fuera de 0g; no interviene en audio de combate.
- QA: Lobby Running ~0.65; Libre=0; Match=0. Intento de restablecer Volume durante
  Libre vuelve a cero. Al salir se recupera el volumen positivo actualizado (0.9
  en fixture). Sin operaciones RenderStepped añadidas.

#### B15 — retorno normal/anulado

- Lobby envía JobId público de origen y, si se conoce, código/ID del Lobby
  reservado. Match valida SourcePlaceId y coherencia del origen entre participantes.
- Ya no se expulsa individualmente al solicitante de salida: anula y participa
  en el retorno común de todos los aceptados aún presentes.
- `LobbyReturnRoute` conserva un destino por encuentro. Primero origen público
  por ServerInstanceId, o reservado conocido por acceso. Ante fallo síncrono del
  origen, un único reservado alternativo explícito comparte código en reintentos.
- TeleportInitFailed reintenta los participantes fallidos al mismo destino; si
  Roblox informa un Job público resuelto, se reutiliza. Guardar perfiles antes de
  Lobby→Match y Match→Lobby; fallo de guardado no inicia el viaje.
- QA controlada con funciones Runtime completas y transporte simulado: cancelación
  tras primera eliminación devuelve dos juntos y no entrega resultado; final de
  dos victorias devuelve dos al Job de origen; fallo asíncrono de uno conserva
  destino; dos errores de origen crean un solo fallback para ambos.
- Studio no valida teleports reales, capacidad, cierre del origen ni comportamiento
  de VIP/cross-play. Origen reservado solo se recupera cuando hay acceso conocido;
  sin acceso se utiliza el fallback común. Revalidar con tres cuentas.

#### B16 — resultados y tablas

- Elegido VICTORIAS VS para la placa antes titulada PARTIDAS. Nuevo `stats.vsWins`
  y OrderedDataStore `ZeroBreach_Rank_VSWins_v1`. Una victoria al ganar el encuentro
  completo; una `matchesPlayed` para cada participante al completarlo, no por ronda.
  Una partida anulada no entrega partida completa, victoria ni premio de final.
- `VsResultService` aplica resultado/misión y recompensas existentes +15 jugar,
  +30 extra ganar; `completedVs` retiene 64 IDs recientes para deduplicar. MatchId
  usa GUID de servidor. La misión VS se registra al finalizar, no al volver por
  TeleportData. Libre conserva su progreso de misión por entrada; no suma victorias VS.
- `DailyMissionCatalog` comparte definiciones en ambos Places. Resultado no rellena
  recursos y preserva las demás misiones del día. No se modifican precios/balance de arma.
- CONGELADOS MODO LIBRE conserva `limbsFrozen` y valores existentes; nuevas
  acreditaciones solo para Libre y jugadores válidos de la misma batalla mediante
  BattleStats. El contador Tab de batalla sigue funcionando tanto en Libre como VS.
- RankService mantiene snapshots autoritativos en atributos para que PlayerRemoving
  no reconstruya ceros tras limpiar caché. Solo sincroniza perfiles aplicados;
  monedas Match usa InventoryCoins. Publicar API antes de consultas históricas;
  sincronización de ranking no bloquea guardado. DataService serializa sus escrituras
  por jugador y Match ahora conserva el logro único de misiones del Lobby.
- QA de API real en memoria: ganador +1 victoria/+1 partida/+45 monedas, duplicado
  sin cambios, perdedor +1 partida/+15 sin victoria; saldo 500→560 para dos
  encuentros controlados. Misión play_match=1, energía sin refill, VS no suma a
  tabla Libre, Libre sí, ledger/logro preservados y snapshot con caché vacía correcto.
- No reconstruye victorias antiguas ni separa estadísticas históricas mixtas.
  Ledger acotado/guardado serializado no es bloqueo de sesión ni una transacción
  DataStore entre servidores. Reconexión, teleport y fallo de guardado reales
  siguen pendientes de prueba publicada.

Compilación final y fuentes iguales de GrabController (15937 bytes/hash
4086773193) y ZeroGFootsteps (3178/hash 3037783418) en ambos Places. Rótulo Libre
ajustado a TextWrapped para mostrar el título completo. Fixtures/mediciones
retirados y ambos Places terminan en Edit.

### Validación publicada y nuevos fallos — reporte del usuario, 2026-10-09

- Calendario/fecha/futuro/cobros/reapertura correctos; arma, apuntado y Beam vistos
  por otro jugador correctos. Libre: daño/feedback/respawn protegido, X, física del
  superviviente y reentrada correctos. VS: ingreso conjunto, countdown, rondas,
  apuntado, mejor de tres y resultado correctos; abandono anula correctamente.
- Se actualiza alcance de B12: disparo/observador remoto en VS confirmado por
  usuario. No implica verificación de todo rig Motor6D/ragdoll alternativo.
- B13: GrabController solo comprobaba existencia de parte, no su vigencia;
  watchCharacter solo creaba prompts al activar cubrirce, sin retirarlos al desactivar.
- B14: Sound `HumanoidRootPart.Running` de volumen ~0.65 no tenía política 0g.
- B15: retorno normal hacía ShouldReserveServer=true (Lobby nuevo); abandono
  enviaba primero al solicitante individualmente y al resto por otra ruta grupal.
- B16: finishMatch no registraba una partida completa. RankService podía borrar
  caché antes de captureProfile en PlayerRemoving; Match además guardaba/logueaba
  ranking de monedas como 0 al no tener leaderstats. Nuevo ranking elegido:
  VICTORIAS VS, no cada ronda; anulación sin victoria. Congelados se titula MODO LIBRE.
- Prueba reportada por usuario; no se proporcionaron versiones ni capturas.
  Correcciones posteriores deben republicarse y repetir los casos fallidos.

### B12: Match conservaba IK antiguo sobre rig moderno — 2026-10-09

- **Reproducido:** avatar Match con 15 AnimationConstraint. Funciones exactas del
  controlador anterior en LocalScript temporal: 35 muestras, alineación mínima
  Muzzle/dirección 0.351407. El IKControl antiguo no orientaba adecuadamente el brazo.
- **Causa:** el arreglo de dos segmentos del Lobby del 07/10 no estaba en Match.
- **Corrección:** sincronizar solo el estado/funciones/hooks de apuntado con Lobby.
  Rigs modernos usan Transform de hombro/codo/muñeca después de Animator;
  restauración antes de animación y al dejar de apuntar. Motor6D conserva IKControl.
  No se editan RigAttachments, estadísticas de arma ni lógica de ronda.
- **Verificado:** funciones nuevas exactas, 105 muestras en tres direcciones,
  dot mínimo 0.9999065. Guardia ZB_Ragdoll no alteró Transform en comprobación
  controlada; limpieza de capa/objetivos y fixture al terminar.
- Fuentes ShootingController idénticas en ambos Places: 22375 bytes,
  hash 2798386865. Backup Match en `ServerStorage.ZB_CalendarAndAimBackup_20261009`.
- **Límite:** Match aislado continúa rechazando TeleportData; esta medición verifica
  pose, no una partida VS ni impactos reales. Validación de dos cuentas, observador
  remoto, Motor6D y ragdoll completo pendiente. Cerrado en Studio, sin publicar.

### Calendario real de actividades — 2026-10-09

- Sustituida lista aislada por plantilla mensual editable en StarterGui de Lobby.
  Mantiene los remotes/cobros B11; fechas de otras jornadas no usan progreso de hoy.
- Exponer `lastClaimDay`/`lastClaimReward` en DailyRewardState permite marcar el
  último cobro confirmado. No existe historial completo de misiones o cobros;
  la GUI identifica la ausencia de registros y no los infiere a partir de la racha.
- Verificado navegación, años bisiestos, cobros 500→590, nuevo día sin pago adicional,
  respawn único y composición desktop/teléfono. Detalles en CHECKLIST/UI_ASSETS.
- Plantilla protegida del layout anterior de AtlasUIController. Bordes de botones
  usan UIStroke.ApplyStrokeMode=Border; leyenda vertical ajustada tras inspección.
- Pruebas móviles visuales en simulador; apertura/scroll por propiedades del cliente,
  no certifican touch. Ambos Places en Edit; simulador default; sin publicación.

### B11: misiones y calendario permanecen en el día anterior — 2026-10-09

- **Reproducido Lobby:** reloj controlado pasó del día UTC 20735 al 20736 sin
  cerrar la sesión. El cliente mantuvo `Reclamada`, monedas 25/25 y daily 1/1.
  Se instrumentó únicamente la lectura del reloj de los servicios originales;
  las fuentes originales se restauraron antes de implementar el arreglo.
- **Causa:** MissionService aseguraba el día solo al entrar/consultar/progresar/cobrar;
  DailyRewardService calculaba disponibilidad al entrar/cobrar. No había aviso de
  cambio de día ni solicitud de snapshots al abrir DailyActivities.
- **Corrección Lobby:** ModuleScript de servidor `DailyClock` comparte día UTC,
  hora Unix y siguiente reinicio (00:00 UTC). Los dos servicios revisan el día cada
  2 s y envían estado solo cuando cambia o hace falta el snapshot inicial.
  `RequestDailyActivitiesState` recupera ambos estados al iniciar/abrir calendario,
  con límite de una solicitud por segundo en cada servicio. No recibe un reloj del cliente.
- **Interfaz:** cuenta atrás `Reinicio UTC en HH:MM:SS`, basada en snapshot del
  servidor; actualización de texto a 1 Hz y rechazo de snapshots de días anteriores.
- **Regresión evitada:** asegurar/progresar/cobrar una actividad ya no reaplica
  perfil completo ni rellena stamina/gancho. `DataService.updateProfile` admite
  `{applyProfile=false}` y sincroniza el saldo si cambia. API agregada también en
  Match; las llamadas existentes con dos argumentos conservan su comportamiento.
- **Verificado:** panel abierto se actualizó a 0/25 y 0/1, daily disponible +75;
  panel cerrado y salto de dos días terminaron en 0 y +50 según la política existente.
  Respawn conserva un calendario. Saldo 500→630 (+50 daily/+80 misión),
  luego 630→705 (+75 nuevo día); solicitudes daily repetidas no duplicaron y
  cobro de misión del día anterior se rechazó. Renovar el día no otorgó monedas.
- **Recursos:** gasto mediante Stamina.spend y progreso real dejaron 30→30;
  prueba de la API de metadatos en Match también 30→30.
- **Límites:** cobros probados en una sesión Studio con DataStore desactivado por
  la política existente. No demuestra idempotencia entre servidores, fallos de
  guardado ni persistencia por reconexión/teleport. Regla de partidas/ranking sin cambios.
- Respaldo por Place: `ServerStorage.ZB_DailyRolloverBackup_20261009`. Fixtures de
  reloj/medición retirados; arranque posterior con reloj real mostró 3 misiones,
  cuenta atrás UTC y saldo inicial 500, sin errores nuevos. Ambos Places en Edit;
  sin publicación. **B11 cerrado en implementación/QA Studio; validación Player pendiente.**

### Arma de primitivas solo local y Muzzle ausente en servidor — 2026-10-09

- **Reproducido Lobby:** cliente tenía `ZB_Blaster` procedural; servidor no tenía
  ese modelo. `ShootingService.getMuzzlePosition` caía al HumanoidRootPart, por
  lo que el visual local y el origen autoritativo no usaban la misma boca.
- **Corregido en ambos Places:** plantilla SDR-Mk2 en
  `ReplicatedStorage.WeaponAssets.Templates.blaster`, montada por el nuevo Script
  `ServerScriptService.WeaponVisualService`. Constructor procedural local deshabilitado.
  Mantener nombre técnico `ZB_Blaster`/`Barrel.Muzzle` conserva los consumidores existentes.
- **Verificado Studio:** una arma de 18 piezas/14 mallas en servidor y cliente,
  sin colisiones ni masa adicional; respawn real en ambos Places sin duplicados.
  Capturas del montaje. Disparo de Libre con mouse, Beam conectado al Muzzle;
  36 muestras de alineación con dot mínimo 0.999809. Salida X conservó una arma.
- **QA controlado:** cambio WeaponId a rifle y restauración sin duplicados;
  gasto de 70 mediante API real de Stamina y cambio de visual: 30→31.8, sin refill.
  apply/reset de CombatRagdoll conserva WeaponMount. No equivale a eliminación
  multijugador ni a validación de todos los rigs. Fixture y atributos QA retirados.
- **Pendiente:** producción multicuenta, VS real y permisos/carga de mallas.
  Respaldo y reversión en DISENO. Sin publicación; ambos Places terminan en Edit.
- **ZB_Intro:** el aviso histórico no reapareció en este arranque. No se corrigió
  ni se cerró el pendiente por esa ausencia; AtlasUIController permanece sin cambios.

### Libre: salida sin traslado y brazo sin apuntado — 2026-10-07

- **Retorno reproducido:** `FREE_LOCAL_EXIT` dejaba GameMode=LOBBY y
  BattleParticipant=false, pero el personaje seguía en la arena. El servidor
  buscaba `workspace:FindFirstChild('SpawnLocation')`; el spawn real está dentro
  de `Workspace.The Spawn Point Light`.
- **Corrección Lobby:** `LobbyTeleportService.returnToLobby` usa RespawnLocation
  o busca SpawnLocation recursivamente, endereza al personaje, limpia velocidades
  y restaura locomoción. `LobbyReturnTransition` y `LobbyReturnController`
  confirman el CFrame en el cliente dueño de red y restauran cámara/cursor.
  Reafirmaciones acotadas se descartan si cambia personaje, serial o participación.
- **IK reproducido:** avatar actual con 15 `AnimationConstraint` y sin Motor6D;
  el IKControl anterior no resolvía el objetivo sobre esa cadena en la prueba.
- **Corrección Lobby:** `ShootingController.client` conserva IKControl para rigs
  legacy y agrega IK analítico de dos segmentos para el brazo derecho moderno.
  Compone Transform de hombro/codo/muñeca en PreSimulation, restaura la capa antes
  de evaluar Animator y al dejar de disparar; no cambia RigAttachments ni detiene
  la pista de flotación para apuntar.
- **Verificación:** salida con X al spawn anidado, cámara Custom/cursor Default,
  caminar 16, AutoRotate=true y PlatformStand=false. IK moderno: 37 muestras
  después de calentamiento, dot mínimo arma/dirección `0.9999974`; swim activo con
  peso 1 en las 37. Medición con funciones exactas mediante LocalScript temporal,
  eliminado después; no es validación multijugador del disparo.
- **Pendientes:** sincronizar el apuntado compartido al Match tras confirmar ese
  alcance; probar rigs legacy, ragdoll moderno y apuntado remoto en producción.
  La espera de `AtlasUIController` por `ZB_Intro` sigue apareciendo, independiente.

### Edición 3D desalineada y pivotes desplazados — 2026-10-07

- **Reproducido en Lobby:** estructura principal con Y=`7.663°`, piso con
  Y=`8.965°`, modelos importados con pivotes alejados de su caja. Agregar piezas
  alineadas a Studio requería giro y centrado manual adicionales.
- **Corrección:** transformación global del Lobby, origen en superficie central
  del piso y alineación de estructura principal; ajuste adicional del piso.
  Pivotes de 58 modelos estáticos centrados y alineados sin mover sus piezas.
- **Dependencia corregida:** límites/slots absolutos de `FloatingRobloxBlocks.server`
  reemplazados por una región física editable `Arena.BlockSpawnRegion`.
- **Prevención:** herramientas `ServerStorage.Editor3D`, documentadas en REGLAS,
  con registro de Undo para operaciones de edición. No es un automatismo Toolbox.
- **Verificado:** posiciones de 628 piezas, pivotes de 58 modelos, fixture de
  colocación eliminado y Play Solo con 16 bloques flotantes/spawn trasladado.
  Alcance Lobby; Match y producción no validados.
- **Observación independiente en Play:** aviso de espera indefinida de
  `AtlasUIController` por `PlayerGui.ZB_Intro` (línea 242), pendiente de investigar.

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
