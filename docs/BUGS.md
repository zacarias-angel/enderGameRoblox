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
| B10 | Alta | Corregido en Studio: UI estirada y manual duplicado. Atlas nuevos integrados el 13/10 con recortes reales, Fit/Slice, texto independiente y respaldo nativo; respawn único en ambos Places. Validación Player/touch pendiente |
| B11 | Alta | Renovación diaria en sesión abierta: reproducida, corregida y verificada en Studio el 09/10. Falta validar medianoche/reconexión en Player; cobro persistente y ranking siguen abiertos |
| B12 | QA publicada parcial | Usuario confirma arma/apuntado/Beam y observador remoto en Libre/VS; rigs alternativos siguen pendientes |
| B13 | Alta / corregido Studio | Cancelación sin impulso, epoch de cuerpo, limpieza de etiqueta y salida comprobados; repetir con dos jugadores publicados |
| B14 | Media / corregido Studio | Running silenciado en 0g y restaurado en Lobby; repetir escucha real/primera persona publicada |
| B15 | Alta / corregido Studio | Origen público, anulación grupal, reintento y fallback común comprobados con transporte simulado; teleport real con tercero pendiente |
| B16 | Alta / corregido Studio | VICTORIAS VS, encuentro completo deduplicado y congelados Libre; API/guardado en memoria comprobados, persistencia publicada pendiente |
| B17 | Alta / corregido Studio | Agarre disponible durante gancho; relevo retira tracción sin borrar impulso. Prompts con registro fuerte y limpieza. QA controlada en ambos Places; recorrido con Q/E y touch publicado pendiente |
| B18 | Media / corregido Studio | AtlasUIController inicia sin esperar ZB_Intro; manual tardío enlazado por eventos, sin fallback vacío. Clicks y respawn comprobados en ambos Places; Player pendiente |
| B19 | Alta / corregido Studio | SpawnShieldRojo/Azul pierden el anclaje por MatchArenaPhysics. Excluir modelos SpawnCover; dos arranques Studio conservan las diez piezas fijas. Repetir dos entradas VS publicadas pendiente |
| B20 | Media / corregido Studio | Calendario solo distinguía hoy/último cobro; no había historial por fecha. Nuevo `DailyClaimHistory` + colores verde/rojo/ámbar. Migración conserva último cobro; días previos sin registro quedan "sin datos". Validar medianoche/reconexión publicada |
| B21 | Alta / corregido Studio | Touch de disparo no permite seguir al enemigo con cámara. Delta táctil por dedo y cámara de combate móvil; fire+arrastre comprobado en simulador. Teléfono físico y VS real pendientes |
| B22 | Alta / corregido Studio | Móvil se sujeta pero no puede soltar/impulsar: salida dependía de E/hold-ended. Gancho cambia a IMPULSO; pulsación táctil simulada desancla y aplica 90 studs/s. Teléfono físico y cuerpos publicados pendientes |
| B23 | Media / corregido Studio | El marco del manual no cambiaba: el arte visible es `ZBAtlas_Background` inyectado desde `Skins.panel`, no el fondo editado. Nuevo slot `Skins.intro` + guía anti-errores; cambio aislado verificado. Falta aplicar el arte nuevo |

La estabilización base de Libre/VS fue validada en producción el 2026-09-14.
Las verificaciones locales posteriores no cierran automáticamente estos pendientes.

## 2. Registro de causas y correcciones

### Marco del manual no cambia en Play — B23, 2026-10-19

- Reporte: se intentó cambiar el marco del manual; en Edit se ve un resultado,
  en Play aparece el marco viejo. También se probó `ZB_Intro.Enabled`.
- **Causa 1 (copia de Play):** mientras la prueba está corriendo, `StarterGui`
  ya fue copiado a `PlayerGui`. Editar `StarterGui.ZB_Intro` no modifica la copia
  activa. Verificado: `PlayerGui.ZB_Intro.Enabled=false` sí oculta el manual.
- **Causa 2 (skin inyectado):** el marco visible no es el fondo del panel. El
  panel tenía `UIFrameSkin="panel"`; `UIAssetSkinController` clona
  `UIAssets.Skins.panel` como `ZBAtlas_Background` y pone el fondo propio en
  transparente. Cambiar `BackgroundColor3`/`UIStroke` del panel no cambia el arte.
- **Causa 3 (layout):** `AtlasUIController.intro()` fija tamaño del panel
  (700×540, 740×340, 370×650) y posiciones de filas/botón en Play; los ajustes
  manuales de tamaño/posición se revierten.
- **Causa 4 (loading):** `LoadingScreen.client` hace `intro.Enabled=true` al
  terminar la carga. Por eso `Enabled=false` en StarterGui no impide que aparezca
  al entrar; para saltearlo hay que modificar el flujo de carga.
- **Corrección de flujo:** primero se creó `Skins.intro` para aislar el marco
  compartido; luego el usuario entregó una **placa completa** y un **botón entero**.
  El manual ahora usa `FullArtIntro=true`: `Instructions.Artwork` (1024×768,
  `98656833460778`) contiene marco, títulos y filas; `Continue` es ImageButton
  (`106514786390752`, 1024×341) debajo. `Logo/Title/Subtitle/Rows` quedan ocultos
  y `UIFrameSkin` vacío. `Skins.intro` se conserva para un marco 9-slice opcional.
- **Layout:** `AtlasUIController` toma como referencia el panel/placa/botón del
  template y escala todo junto para el viewport; el botón conserva la posición y
  tamaño que el usuario le dio en Edit (hoy superpuesto al borde inferior, sin
  tapar la última fila). `IntroMaxWidth` limita el ancho. Si falta `Artwork`/Image,
  vuelve al manual clásico para no quedar en blanco.
- **Verificación:** Lobby escritorio y iPhone 17 Pro 750×381 con placa/botón
  cargados, sin solapamiento; clic en ENTENDIDO cierra (`Enabled=false`). Match
  habilitado localmente: ambos recursos `Success`, clic cierra. `Skins.panel`
  conservó su ID. Guía y especificación en UI_ASSETS 0.9; `frame_9slice_guide.png`
  (1024×1024, esquinas 96, `SliceCenter` 96/928) para futuros marcos.
- **Límite:** sin publicación; falta teléfono físico y aceptación visual final.
  El texto quedó incorporado en la placa: cambios de controles exigen nueva imagen.

- Reporte del usuario: puede girar cámara sin disparar, pero no mantener seguimiento
  del enemigo al disparar; puede sujetarse tras usar gancho, pero no liberarse ni
  impulsarse. También solicita quitar SUBIR/BAJAR y ampliar los dos botones restantes.
- **B21:** el botón consumía el toque como GUI; no había puente para su arrastre,
  y BattleCameraController excluía explícitamente `TouchEnabled`. Nuevo módulo
  `MobileAimInput` registra posiciones por InputObject y acumula delta. MobileControls
  registra el dedo de fire/hook; la cámara acepta TouchMoved incluso procesado por
  GUI, pero solo mueve gestos previamente registrados. Otro dedo derecho libre
  también apunta; tocar joystick/UI no inicia un gesto de cámara. Se conserva
  la intención de fuego al salir del círculo, hasta End/Cancel real del dedo.
- Cámara orbital compartida con escritorio, colisión y restauración al salir;
  sensibilidad táctil editable, sin bloquear el frame ni depender de la energía.
- **B22:** liberar dependía de `PromptButtonHoldEnded` o de terminar la tecla E;
  un tap táctil de prompt con HoldDuration=0 no daba una acción persistente de salida.
  Nuevo `launch` en LocalCombatInput: Hook se presenta como IMPULSO mientras está
  sujeto y llama a `finishGrab(true)`. Al agarrarse se retira intención previa de
  hook; liberarse no relanza el gancho automáticamente. Cancelación mantiene la
  ruta sin impulso. Touch conserva el agarre hasta esa pulsación; teclado sigue
  mantener/soltar E. Se ocultan prompts durante el agarre y se restauran después.
- Up/Down eliminados solo de la UI/bindings móviles. Botones Fire/Hook de 112/96 px
  o 96/84 px en pantalla baja; estado de impulso dorado, dos acciones en total.
- **QA Lobby:** Libre por remote real. Intenciones sostenidas y dos dedos simulados
  giran sin soltar fire; Touch del simulador verifica arrastre desde fire (dot≈0.982).
  Pieza temporal agarrada con E y botón IMPULSO tocado: root desanclado, velocidad
  inicial 90, alineación 1 con `-camera.LookVector`, Caption vuelve a GANCHO.
  Menú limpia fire/delta sin reactivar al cerrar. El fixture de prompt mediante
  InputHoldBegin no activó el evento; se utilizó E para iniciar esa prueba.
- **QA Match:** escenario local controlado sin TeleportData, no ronda real;
  fire+gesto y segundo dedo pasan (dot≈0.981), menú cancela. Capturas de iPhone 17 Pro
  750×381 y Galaxy A06 705×338 sin acciones superpuestas y con textos completos.
- Respaldo por Place `ZB_MobileAimReleaseBackup_20261019`. Cinco fuentes compartidas
  iguales por hash; fixtures/puntos de depuración retirados. Ambos en Edit/default,
  sin publicar. Falta touch físico, agarre iniciado por prompt táctil, cuerpo
  congelado, observador remoto y recorrido VS/retorno reales.

### Cambio visual: cuerpo congelado azul hielo — 2026-10-19

- Pedido: al congelar un jugador, reemplazar el rojo por azul con material hielo.
- Causa del rojo: `FreezeService.server` interpolaba el torso hacia
  `Config.LedColors.FROZEN` RGB(255,82,82) y usaba el mismo valor al eliminar.
  El material ya era Ice, pero se teñían solo cabeza/torso al completar el porcentaje.
- Ajuste compartido: nueva configuración `FreezeAppearance`, azul parcial
  RGB(140,210,255), total RGB(75,180,255), material Ice. El total afecta las partes
  corporales directas excepto root; parcial admite también Torso R6.
- Se conserva restauración previa por pieza y no se reutiliza la constante roja
  del HUD para pintar el cuerpo. Armas/accesorios anidados no se tiñen.
- QA de Play con clon R15, FreezeService real y sin recompensas: parcial→100,
  **15 partes** verificadas por Place, reset de color/material, reset repetido y
  segundo congelamiento; Lobby y Match pasan. Un primer fixture de QA usó resta
  de Color3 no admitida; se corrigió su comparación, sin cambiar lógica del juego.
- Respaldo `ZB_IceAppearanceBackup_20261019`; fixtures runtime retirados al detener
  Play y ambos Places en Edit. No publicado; falta combate entre cuentas reales,
  observador remoto y prueba de R6. No cierra los pendientes B03/B13 de producción.

### Historial y colores de días en el calendario — B20, 2026-10-16

- Reporte del usuario: los días reclamados debían verse en el calendario —verde
  si se reclamó, rojo si no, otro color si está disponible. Antes solo existía
  `daily.lastClaimDay`/`streak`: se marcaba hoy y el último cobro, sin historial.
- **Causa:** no se persistían los días cobrados, así que no había forma de pintar
  días pasados como reclamados o perdidos.
- **Corrección:** nuevo ModuleScript de servidor `ServerScriptService.DailyClaimHistory`
  (normaliza/consulta/registra). `daily` guarda `claimedDays` (fecha→importe),
  `historyStartDay` y `historyVersion=1`. `DailyRewardService.server` acredita saldo
  y fecha en la **misma** mutación atómica del perfil, con guarda para no pagar dos
  veces. `DataService.server` de Lobby y Match normaliza al cargar y preserva el
  historial al capturar/guardar (no lo pierde al viajar). El calendario
  (`StarterPlayerScripts.DailyActivities`) pinta por estado y expone los colores
  como Attributes del ScreenGui.
- **Límite honesto:** los días anteriores al registro quedan como `SIN DATOS`
  (gris); no se pintan de rojo para no inventar historial. El perfil antiguo solo
  migra su último cobro confirmado. Match no tiene calendario propio (es de Lobby),
  pero guarda el mismo historial para no perderlo en el teleport.
- **QA (reloj de prueba en memoria):** migración `lastClaimDay=base-2,streak=2`
  conservó ese cobro; cobros de UI base/base+2 dieron 500→550→600; base+1 quedó
  `missed`; tres solicitudes repetidas no duplicaron; captura/guardado preservó 3
  fechas, el hueco y el saldo 600. Match verificó la preservación del historial al
  guardar. Smoke test con reloj real: hoy `available`, 18 `unknown`, 23 futuros.
  `DailyClaimHistory`/`DailyClock` idénticos por hash entre Places. Sin fixtures;
  respaldo `ServerStorage.ZB_DailyHistoryBackup_20261016`. Sin publicar.
- **Pendiente:** prueba publicada de medianoche real, reconexión y cruce
  Lobby→Match→Lobby; y que el saldo del cobro se gaste/persista con DataStore real.

### Escudos de spawn flotando en la segunda entrada VS — B19, 2026-10-14

- Reporte del usuario: dos entradas al 1v1 con cuentas reales; la primera funcionó,
  pero al salir y volver a entrar SpawnShieldRojo y SpawnShieldAzul estaban flotando.
- Inspección Edit en Match `108298899371591`: ambos modelos en
  `Workspace.Arena.SpawnCovers`, atributos `SpawnCover=true` y `cubrirce=true`;
  cinco piezas ancladas por modelo, con dos trims decorativos sin colisión.
- Causa reproducida en Play Server: `ServerScriptService.MatchArenaPhysics.server`
  procesa todos los modelos `cubrirce=true` como coberturas dinámicas. Cambia todas
  sus piezas a `Anchored=false` y `CanCollide=true`, y crea cuatro welds por escudo.
  Antes del fix: **0/10 piezas ancladas**, cuatro trims con colisión y ocho welds.
  El fallo ocurre al inicializar Match; no se encontró un desanclaje específico de
  la segunda ronda. En gravedad cero, los escudos quedan expuestos al desplazamiento
  por contacto/impulso, aunque una primera partida parezca correcta.
- Corrección: `weldModel` retorna sin modificar los modelos con `SpawnCover=true`.
  Conserva anclaje y colisiones por pieza definidos en Studio. `cubrirce` sigue
  presente para la interacción de agarre. No se cambian posiciones ni geometría.
- Alcance: Match solamente. Lobby inspeccionado sin modelos `SpawnCover`; no requiere
  replicar un script de física exclusivo del Match.
- QA: dos arranques Play consecutivos de Match, cada uno con impulsos aplicados
  a los escudos y observación posterior de 1 s. En ambos, **10/10 ancladas**, trims
  sin colisión, ningún weld añadido y desplazamiento máximo **0 studs**. Las otras
  **16** coberturas dinámicas mantienen **48** piezas sin anclar y **32** welds.
- Output sin errores nuevos de MatchArenaPhysics; Play aislado conserva rechazo
  de TeleportData y errores HTTP de retorno del entorno. Ambos Places en Edit.
- Respaldo: `ServerStorage.ZB_SpawnCoverBackup_20261014` en Match, con fuente
  anterior identificada por OriginalPath y clones de los dos escudos originales.
  Para revertir el fix basta restaurar la fuente; no insertar clones adicionales
  de los escudos en Workspace.
- **Sin publicar.** Falta publicar Match y repetir entrar→salir→entrar al 1v1 con
  las dos cuentas, en servidores Match nuevos. Estos dos arranques Studio no
  certifican la secuencia real de teleports ni cierran toda la aceptación VS.

### Prevención de regresión B10 al integrar atlas — 2026-10-13

- Fuentes nuevas no cumplen las dimensiones nominales del prompt: 1254×1254
  iconos/marcos y 1774×887 botones. No reutilizar coordenadas del atlas histórico.
- Los marcos tenían un damero pintado (alfa 255 en toda la fuente); recortes
  procesados a transparencia real antes de subir. Iconos y botones sí tenían alfa.
- 16 iconos Fit, 8 estados y 4 marcos Slice en ambos Places; fondos separados
  de textos y escala uniforme de esquinas. Datos/IDs/edición en UI_ASSETS.
- Detectado y corregido durante integración: una imagen oculta podía no cargar,
  y esperar solo IsLoaded dejaba fondo/texto sin sincronizar. El arte se solicita
  visible; AssetFetchStatus y cierre de precarga sincronizan con respaldo nativo.
- Corregido contraste del texto oscuro de Reclamar sobre el fondo violeta.
- QA Studio: 28/28 recursos cargados en ambos clientes, capturas desktop y
  simulador horizontal/vertical, estados de botones y respawn sin fondos duplicados.
  Simulador no certifica touch; falta Player. Respaldo `ZB_UIAtlasBackup_20261013`.

### Agarre durante gancho y arranque del manual — B17/B18, 2026-10-13

**Implementados y verificados en Studio en Lobby y Match; sin publicar.**
Respaldo de los tres controladores por Place:
`ServerStorage.ZB_GrabHookBackup_20261013`. Para revertir, restaurar sus fuentes
en `StarterPlayer.StarterPlayerScripts`, con Play detenido.

#### B17 — no aparece la opción de agarrarse durante el gancho

- Reporte del usuario: al usar el gancho y pasar cerca de un elemento agarrable,
  ya no aparece la opción de sujetarse.
- Causa reproducida con la función vigente exacta: `canGrab()` devolvía
  true→false→true al cambiar `Hooking` false→true→false. Esa condición también
  deshabilitaba los prompts y rechazaba `startGrab` durante la tracción.
- Corrección: el gancho no bloquea la disponibilidad del agarre. Al activar
  voluntariamente E, `Grabbing` hace que HookController suelte el gancho y retire
  su fuerza/visual; guardia adicional en Heartbeat. El relevo no escribe velocidad:
  GrabController conserva el frenado y el impulso al soltar. Mantener la tecla de
  gancho no lo relanza automáticamente; lanzar mientras se está sujeto se rechaza.
- Registro de prompts con referencias fuertes y retiro por `Destroying`:
  las claves Instance débiles podían perder el seguimiento aunque el prompt
  siguiera en Workspace. Endurecimiento adicional; no se aisló el GC como causa
  del reporte. Los avisos también respetan scoreboard y cursor libre de escritorio.
- QA sobre los controladores ejecutándose, con atributos controlados: **61**
  prompts habilitados en Lobby y **58** en Match antes/durante/después de Hooking;
  menú, scoreboard y countdown dejan **0**, reactivar restaura 61/58.
- QA con funciones exactas, superficie temporal y transporte simulado en ambos
  Places: gancho→agarre, fuerza cero, root sujeto, rechazo de otro gancho, soltar
  con velocidad 90, liberación posterior del gancho sin borrar impulso, una señal
  de release y un lanzamiento. Invalidar cobertura o abrir menú cancela sin impulso;
  countdown rechaza agarre.
- Alcance: la integración anterior simula raycast/transporte; no certifica energía
  ni visual remoto en multijugador. El intento adicional de teclado Q/E no fue
  concluyente por desplazamiento del personaje respecto al fixture. Falta recorrer
  coberturas reales con Q/E y gancho/agarre táctiles en Player, y repetir B13 con cuerpos.

#### B18 — espera de ZB_Intro bloquea el resto de AtlasUIController

- Reproducido en el arranque de Match: aviso `Infinite yield possible` en
  `PlayerGui:WaitForChild('ZB_Intro')`, antes de crear ayuda y conectar observadores.
  La copia del manual puede llegar tarde; el aviso por sí solo no demuestra espera infinita.
- Retirada la espera y el fallback ScreenGui vacío. `watch`/`ChildAdded` enlazan
  la plantilla al aparecer. Ayuda solo se muestra con manual completo y busca
  la instancia actual al pulsar; las otras pantallas pueden iniciar sin el manual.
- QA controlada con el controlador exacto y contenedor aislado en ambos Places:
  inicia sin manual, ayuda oculta, copia tardía enlazada, abrir bloquea input y
  cerrar lo libera; **un manual**, sin fallback.
- QA de UI real por mouse en ambos Places: ayuda abre, Continue cierra y
  `ZB_MenuOpen` true→false. Respawn real conserva un manual y un acceso de ayuda;
  root desanclado y Grabbing=false. Nuevo arranque sin aviso de ZB_Intro ni errores
  nuevos de los controladores; Match aislado conserva rechazo de TeleportData/HTTP.

Fuentes iguales y compiladas en ambos Places (hash polinómico base 31, módulo 2^32):
GrabController **16406 bytes / 3943661661**; HookController **14923 / 1815726232**;
AtlasUIController **18981 / 3906578620**. Fixtures y atributos de prueba solo en
runtime, retirados al detener Play; auditoría final sin `ZB_QA_*`. Ambos Places en Edit.

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
