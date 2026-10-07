# ZERO BREACH — Checklist, pruebas y progreso

Actualizado: 2026-10-07. Diseño en [DISENO](DISENO.md), normas en
[REGLAS](REGLAS.md), incidentes en [BUGS](BUGS.md).

## 1. Estado y prioridad inmediata

### Libre: retorno al Lobby y apuntado — 2026-10-07

- [x] Reproducir salida sin traslado: spawn anidado no encontrado por búsqueda directa.
- [x] Corregir `LobbyTeleportService`; añadir transición dirigida y
  `StarterPlayerScripts.LobbyReturnController` para sincronizar el dueño de red.
- [x] Probar X en Play Solo: LOBBY, participante=false, root a 3.881 studs sobre
  spawn, caminar 16, AutoRotate=true, PlatformStand=false, cámara Custom,
  MouseBehavior.Default y fuerza local de empuje retirada.
- [x] Detectar avatar con AnimationConstraint en lugar de Motor6D; adaptar
  `ShootingController.client` con IK de dos segmentos para hombro/codo/muñeca.
- [x] Comprobar capa moderna con funciones exactas en LocalScript de QA temporal:
  37 muestras, dot mínimo arma/dirección 0.9999974 y pista swim con peso 1.
  Las pruebas de mouse posteriores fueron bloqueadas por foco CoreGui; esta
  medición valida la pose, no un click de disparo de extremo a extremo.
- [x] Segunda salida mediante LeaveMatchRequest real del cliente: traslado y
  locomoción correctos; fixture y atributos de medición eliminados con la prueba.
- [x] Compilar los tres scripts modificados/creados; terminar Lobby en Edit.
- [ ] Repetir disparo manual con mouse enfocado, respawn/ragdoll, rigs Motor6D y
  dos clientes; aplicar apuntado al Match cuando se confirme ese alcance.
- [ ] Resolver espera independiente de ZB_Intro; sigue registrada en Output.
- Cambios aplicados solo en Lobby; no publicados.

### Orientación, centrado y colocación 3D — 2026-10-07

- [x] Confirmar con el usuario alcance: Gravedad CERO/Lobby, existentes y nuevos.
- [x] Realinear estructura principal a ejes mundiales; origen en superficie central
  del piso `(0, 0, 0)`, `piso.Position=(0, -0.5, 0)` y Orientation cero.
- [x] Normalizar pivotes de 58 modelos no pertenecientes a personajes.
- [x] Comparar posiciones de 628 piezas con la transformación global esperada:
  error máximo `0.0000211` studs. Piso enderezado adicionalmente; Terrain excluido.
- [x] Crear `Arena.BlockSpawnRegion` y adaptar límites/slots del servidor de bloques.
- [x] Crear `ServerStorage.Editor3D` y verificar normalización sin desplazamiento,
  enderezado por referencia y colocación con base en Y=0 sobre un fixture temporal.
  Fixture eliminado tras comprobar; 58 pivotes de modelos verificados en ejes mundiales.
- [x] Play Solo Lobby: personaje aparece en spawn trasladado, 16 bloques con
  PrimaryPart y fuerza de flotación; power-ups aparecen en puntos trasladados.
  Script de bloques compila. Captura posterior de la escena; Studio termina en Edit.
- [x] Documentar uso en Command Bar y respaldo `ServerStorage.Editor3D_AlignmentBackup`.
- [ ] Validar manualmente recorridos, colas y Libre tras realineación; no se probó
  una partida completa ni teleport. Match no realineado; no se publicó.
- [ ] Revisar aviso observado en Play: `AtlasUIController`, línea 242, espera
  `PlayerGui.ZB_Intro` con `Infinite yield possible`. No corregido en esta tarea 3D.

### Revisión: edición visual y sugerencias — 2026-10-06

- [x] Crear `ReplicatedStorage.UIAssets.Icons`: 27 ImageLabels, cada uno con
  Fallback de Frames y metadatos de entrega. Image se cambia desde Properties.
- [x] Crear `.Styles.panel/card/button` como Frames con UICorner y UIStroke.
- [x] Manual completo en `StarterGui.ZB_Intro` en ambos Places; Title, Subtitle,
  Logo, Rows.Row01..Row08 y Continue con nombres estables.
- [x] UITheme clona esas plantillas; AtlasUIController enlaza el manual sin
  destruir sus textos y Frames. Layout responsive conservado.
- [x] Archivar catálogo Lua anterior y conservar backup de la plantilla Lobby.
- [x] Verificación visual: manual escritorio Lobby, manual vertical Match y
  mochila Lobby con nuevos iconos/estilos; Continue y B siguen funcionando.
- [x] Prueba funcional de edición visual en Lobby: solo propiedades Image de
  Icons.bag, Text de Title y CornerRadius. Nueva sesión mostró título editado,
  radio 20, imagen en botón y manual, IsLoaded=true, Fit y fallback oculto.
  Restaurados Image vacío, título ZERO BREACH y radio 12 después de la prueba.
- [x] Reescribir UI_ASSETS.md con reemplazo por Explorer/Properties.
- [x] Crear SUGERENCIAS.md con nueve cosméticos propuestos, rutas existentes y
  rutas por crear, pases/productos, recibos, videos, anuncios y regalos globales.
- [x] Verificación final: compilación correcta y fuentes iguales en ambos Places:
  UITheme 11733 bytes / hash 467807235; AtlasUIController 18964 bytes / hash 612955664.
  Árbol visual de 454 instancias, 27 iconos y 8 filas; firma de estructura y
  propiedades principales 3097890407 en ambos Places.
- [x] Output sin errores nuevos de UI; Match aislado mantiene rechazo de TeleportData
  ausente. Ambos Places en Edit, viewport default y `UIAssets.Icons.bag` seleccionado
  para encontrar fácilmente el campo Image. Sin publicación ni gastos.
- [ ] Migrar por completo otras pantallas estáticas a StarterGui; pasos en SUGERENCIAS.
- [ ] Implementar las propuestas de monetización/cosméticos/UGC tras decidir
  contenido, IDs y presupuesto. Ninguna venta ni gasto fue activado en esta tarea.

Las verificaciones de la sección siguiente describen la versión previa del mismo
día. Su antiguo ModuleScript UIAssets ya no es la fuente vigente; ver UI_ASSETS.md.

### UI limpia y guía de sustitución — 2026-10-06

- [x] Reproducir la deformación visual del atlas; retirar sus marcos y recortes.
- [x] Paneles y botones nativos; texto original en lugar de etiquetas espejo.
- [x] 27 claves en `ReplicatedStorage.Shared.UIAssets`: trazos nativos actuales y
  campo Image para futuros PNG individuales con Fit, sin recortes ni estiramiento.
- [x] Mochila/tienda en una columna para viewport vertical estrecho; manual y
  actividades reorganizados al rotar. Resize diferido para no perder el UIScale.
- [x] Ocultar accesos de calendario/ayuda/mochila con modal abierto.
- [x] Manual único en Lobby y Match; esperar copia de StarterGui cuando existe;
  plantilla Lobby y GUI runtime con ResetOnSpawn=false.
- [x] Crear [UI_ASSETS.md](UI_ASSETS.md), catálogo y caso «mochila por bolso»:
  rutas locales y Studio, nombres, tamaños, IDs, carga, prueba y reversión.
- [x] Definir `docs/assets/ui/` para entrega de futuros PNG; aclarar que todavía
  no hay imágenes individuales exportadas, porque el acabado actual es nativo.

**Verificado en Studio:**

- Escritorio, simulador Laptop promedio: viewport 1365×768. Manual, mochila y
  tienda con bordes uniformes, iconos completos y texto sin la deformación del atlas.
- Lobby: abrir mochila con B; tienda con E junto al prompt real de `Workspace.Taller`.
  Para llegar al taller se colocó el personaje allí durante Play; no se cambió el spawn.
- Match: mochila con B y cambio a categoría Armas por click; tarjetas regeneradas
  mantienen el nuevo acabado y el estado EQUIPADO.
- iPhone 17 Pro: mochila horizontal Lobby (viewport 750×361), manual y actividades
  verticales Lobby (401×778), actividades horizontales y mochila vertical Match.
  Tras girar en Match, panel 370×650 y escala 1; antes quedaba incorrectamente en 0.39255.
- Algunas pantallas móviles se abrieron/ocultaron por propiedades del cliente
  para inspección visual. No afirmar que esto valida input touch real.
- Tras la corrección final: exactamente un `ZB_Intro` en cada Place. En Lobby,
  click en CONTINUAR deja menú=false y recupera accesos; ayuda reabre el mismo
  manual, pone menú=true y oculta accesos. Respawn real mediante LoadCharacterAsync
  mantiene un único manual, persistente y con su estado de apertura.
- Cero ImageLabels del atlas antiguo en la inspección del PlayerGui; inspección
  previa del runtime Lobby tampoco encontró consumidores del atlas en el mundo.
- Arranque final sin errores de UIAssets/UITheme/AtlasUIController en ambos Places.
  Match aislado rechaza TeleportData ausente y falla el retorno de prueba, como
  corresponde a ese entorno; no es una validación de VS publicado.
- Compilación y paridad de las tres fuentes compartidas, después del último cambio:

  | Script | Bytes | Hash de comprobación (h×31 + byte, módulo 2³²) |
  |---|---:|---:|
  | UIAssets | 4023 | 976538978 |
  | UITheme | 11858 | 3452018274 |
  | AtlasUIController | 20239 | 534430835 |

- Ambos Places terminan en Edit y con viewport default; sin fixtures añadidos.
  No se publicó desde esta sesión.

**Pendiente de validación fuera de esta tarea:**

- [ ] Roblox Player y touch real, incluida la política existente de orientación.
  `StarterGui.ScreenOrientation=Sensor`, pero Match tiene `OrientationLock.client`
  con aviso de girar el dispositivo: adaptar los menús no habilita por sí solo
  todo el gameplay vertical.
- [ ] VS publicado: resultados, roster y feedback con jugadores reales tras el cambio visual.
- [ ] Al entregar un PNG nuevo: comprobar carga, permisos y legibilidad en ambos Places.
  Ningún PNG individual fue activado en esta sesión.
- Compras/cobros/persistencia no se revalidaron en esta sesión: se verificó su
  presentación y se conservaron sus controladores y contratos existentes.

### Controles, energía, tabla y spawns — 2026-10-02

- [x] Corrección posterior de cursor al salir, aplicada a ambos Places:
  no restaurar MouseBehavior/Icon antiguos. Prueba local de transición simulada
  con bloqueo previo: Scriptable→Custom, mouse Default, icono visible y cursor
  libre. Lobby detenido en Edit tras la prueba; sin fixtures persistentes.

- [x] Q/Espacio para gancho y R/Ctrl para deriva vertical; salto del Lobby conservado.
- [x] Cuatro avisos locales de vacío/listo con audio precargado en ambos Places.
- [x] Cámara de escritorio sin RMB, Alt/cursor libre y CTA de mochila.
- [x] Tabla Tab de congelamientos de la batalla, con contador autoritativo separado.
- [x] Ocho puntos de spawn Libre, selección segura y protección 5 s con contador.
- [x] Invalidar callbacks de respawn antiguos y atender reset físico en Libre.
- [x] Recolocar spawns VS, separar compañeros y añadir coberturas frente a ambos.
- Palanca Lobby: **Próximamente**; no funcional por decisión del usuario.

Verificaciones locales realizadas:

- Entrada real mediante API de LobbyTeleportService en fixture temporal:
  BattleParticipant=true, ubicación LibreSpawn válida y escudo rechaza daño parcial.
- Mouse giró cámara ~39° con botón derecho sin presionar; Space activó gancho y
  consumió energía. Alt dejó MouseBehavior=Default; B abrió mochila con cursor libre.
- Cuatro Sounds IsLoaded=true; las cuatro notificaciones vacío/listo se emitieron
  al simular cambios de atributos desde el servidor.
- Snapshot servidor de BattleFreezes=10 se reflejó en la fila de tabla. Esto
  comprueba presentación; acreditación entre dos jugadores sigue pendiente.
- Eliminación real vía FreezeService en QA: LibreSpawn3→LibreSpawn1, progreso
  restablecido, CombatActive=true, escudo nuevo válido y contador limpio al salir.
- BattleStats rechaza objetivo NPC/nil y autoimpacto en comprobación aislada.
- Salida X: BattleParticipant=false, BattleFreezes=0, cámara Custom, mouse Default
  y root vertical (`UpVector·Y=1`).
- Geometría VS: GetPartsInPart comprueba 4/4 slots despejados de Azul y Rojo;
  raycast directo entre spawns golpea cobertura estática en ambos sentidos.
- Ambos Places arrancaron sin errores nuevos; Match sin TeleportData sigue siendo
  rechazado. Fixture GameplayQA_TEMP y sus atributos retirados; ambos en Edit.

Pendientes antes de dar por validada la versión publicada:

- [ ] Dos cuentas: incrementar BattleFreezes con impactos reales, mantener total
  entre rondas/respawns y resetear al salir; comprobar aislamiento de partidas.
- [ ] Probar Q/Espacio simultáneos, chat, pérdida de foco y regreso de cursor en Player.
- [ ] Confirmar mix/volumen y permisos de ambos audios en versión publicada.
- [ ] VS 2v2–4v4 real: spawns, salidas/flanqueo de las nuevas coberturas y cámaras.
- [ ] Probar resets físicos repetidos de Libre y salida/reentrada durante eliminación.

### Rediseño UI con atlas — 2026-10-02

- [x] Importar pack aportado como `105755219623216` y corregir recortes a factor 2/3.
- [x] Tema/controlador compartidos en ambos Places; comparar longitud/hash de fuentes.
- [x] Aplicar presentación a UI de pantalla, instrucciones, ranks, hologramas y taller.
- [x] Conservar compra/equipado/cobro en sus controladores originales.
- [x] Comprobar mochila B, categorías y tarjetas regeneradas en Lobby; mochila Match.
- [x] Abrir tienda con E y comprar recarga: 500→420 monedas, 18→24/s, confirmación.
- [x] Cobrar daily +50 y misión asociada +40: saldo 590, Reclamada/Hecha.
- [x] Capturar placas de ranking con nuevo marco y fila del jugador actualizada.
- [x] Manual de instrucciones con iconos, CONTINUAR y reapertura; ZB_MenuOpen se
  activa al abrir manual/actividades y vuelve a false al cerrar.
- [x] QA de presentación VS: HUD de recursos, score, roster, X, countdown, derrota
  y resultado mediante snapshots enviados por un Script temporal en Studio.
- [x] Retirar `AtlasUI_QA_TEMP`; ningún fixture ni atributo de QA queda en Edit.
- [x] Simulador iPhone 17 Pro horizontal: revisar manual, equipo y actividades;
  corregir composición compacta y prioridad de capas detectadas.
- [x] Detener Play en ambos Places y restaurar simulador a viewport default.
- [x] Arranque final sin errores de UITheme/AtlasUIController en Output de ambos.
- [ ] Publicar y confirmar carga/permisos del atlas en Roblox Player.
- [ ] VS publicado multicuenta: datos reales, feedback de ambos jugadores y resultados.
- [ ] Probar touch real, portrait y dispositivos de gama baja; el juego conserva
  `ScreenOrientation=Sensor`. El simulador horizontal no valida estas condiciones.

Evidencia del tema: fuentes idénticas en ambos Places al cerrar:
UITheme 10409 bytes/hash 3270847715 y AtlasUIController 17194 bytes/hash 503860922,
verificados después de los ajustes finales de capas y menús.
Recompensas y compras comprobadas solo en Play local, no persistencia
publicada. Match aislado continúa rechazando TeleportData ausente como corresponde.
El intento de entrar a Libre por el stand en esta QA no confirmó transición;
el HUD de batalla se comprobó con snapshots de servidor, no como un VS real.

En la consolidación del 02/10 la documentación quedó en cuatro Markdown; el 06/10
se agregó UI_ASSETS.md por pedido del usuario y el README de la carpeta de entrega.

- [x] Leer los 13 documentos presentes, incluida la bitácora completa.
- [x] Consolidar en cuatro archivos y distinguir decisiones actuales de prototipos.
- [x] Detectar referencias obsoletas a `src/`: no existe en el checkout actual.
- [x] Abrir el Lobby y Match en Studio; bloqueo inicial de Place cerrado resuelto.
- [x] Leer CombatFeedback de ambos Places y localizar productores de freezeProgress.
- [x] Aumentar amplitud de shake beam ×5/pulse ×4, conservando retirada de transformación previa.
- [x] Reforzar halo rojo confirmado, ampliar gradiente y mantener centro libre.
- [x] Aplicar los mismos diez cambios en Match; valores registrados en DISENO.
- [ ] Probar disparo, daño repetido, protección, reset, respawn y salida al Lobby.

La documentación de 2026-09-30 ya describe shake leve y cuatro bordes rojos en
CombatFeedback. El pedido actual se implementó reforzando ese mismo sistema.

### Verificación 2026-10-02

- Lobby y Match ejecutaron Play y crearon `ZB_CombatFeedback` con cuatro Frames
  DamageEdge1..4, medidas 20%/16%, Active=false y transparencia inicial 1.
- Output no mostró errores de CombatFeedback. Match mostró los rechazos/retornos
  esperados al entrar sin TeleportData en Play aislado.
- La inyección de daño de QA no pudo ejecutarse: MCP rechazó FireClient de
  StateChanged y la inserción del fixture por restricciones de Capabilities.
  Otro intento de diagnóstico no tuvo acceso a `_G`; esos errores son del
  comando de prueba, no evidencia de fallo del script de feedback.
- No se validaron todavía intensidad percibida, daño real, disparo sostenido ni
  reset completo en combate. Mantener abierta la matriz A.
- Ambos Places quedaron en Edit. No se publicó. `git diff --check` sin errores;
  docs contiene exactamente cuatro archivos.

## 2. Implementado según las sesiones anteriores

- [x] Movimiento 0g con inercia, drag, boost, límite y compensación individual Libre.
- [x] Gancho inmediato con energía propia y remotes asíncronos, FOV y cosméticos.
- [x] Agarre E, impulso inverso del jugador y empuje del objeto.
- [x] Beam autoritativo, progreso acumulado, cabeza x3, VFX replicado y overheat.
- [x] Lobby + Libre local; VS por reservado Match con lista exacta autorizada.
- [x] Stands y colas separadas, capacidad previa, CombatActive y countdown por ronda.
- [x] Mejor de tres, eliminados permanecen entre rondas, retorno grupal reservado.
- [x] Feedback atacante/víctima con avatar y 3 s; X en roster y colores ocluidos.
- [x] Ragdoll reversible real, sin copia superpuesta en VS.
- [x] Respawn Libre en arena con 5 s de escudo cancelable por primer disparo válido.
- [x] Power-ups amarillo/azul/rojo y 15 puntos persistentes en ambos Places.
- [x] Perfiles, autosave/cierre, monedas, taller, estadísticas y cosméticos persistentes.
- [x] Daily, misiones, logro único de +120 y resultados con MVP/estadísticas.
- [x] Ranking reactivo con histórico en segundo plano y Elimination total replicado.
- [x] EquipmentDashboard común; mochila B, tienda E exclusiva del Lobby.
- [x] Recarga permanente +6/s por 80 monedas, base 18/s, máximo 48/s.
- [x] Inventario Match lee workshop; cosméticos no rellenan energía.
- [x] Insignia QA limitada a 10 UserId; entregas deshabilitadas en Studio.
- [x] Limpieza de orientación, pose, cámara y fuerzas al volver al Lobby.

Estas marcas representan implementación documentada; no equivalen a una nueva
auditoría del código ni a validación publicada de todas las características.

## 3. Evidencia existente y límites

### Producción registrada el 2026-09-14

- Libre volvió a mostrar feedback para ambos participantes sin bloqueo prolongado.
- VS recuperó movimiento, 0g y transiciones de ronda durante la prueba publicada.
- No extender esa evidencia a cambios posteriores de ragdoll, UI o recarga.

### Studio registrado el 2026-09-30

- Compilación y arranque de scripts modificados en ambos Places.
- Mochila B y tienda E inspeccionadas visualmente; compra 500→420 monedas y
  recarga 18→24/s, reflejada en perfil de memoria.
- Match: perfil de prueba 30/s regeneró 18 puntos en seis ticks/~0.65 s;
  guardó 30/s en memoria y replicó InventoryCoins.
- Compras sin saldo/al máximo rechazadas sin cobrar ni entregar.
- Disparo real canceló solo escudo de aparición; escudo azul conservado.
- Protección rechazó daño; daño parcial generó borde rojo con desvanecimiento.
- Ragdoll R15: 14 articulaciones físicas, Humanoid vivo, reset de motores;
  respawn Libre y activación/reset aislados en Match.
- Roster simulado: X en eliminación/resultado y limpieza en siguiente ronda;
  contornos con oclusión.
- Salida X: root vertical (`UpVector·Y=1`), sin fuerzas/orientación de combate,
  AutoRotate=true, cámara Custom y zoom restaurado. W/D giró avatar ~90°;
  reentrada recreó física.
- Arrastre automatizado del mouse no cambió mediblemente cámara: **giro de cámara
  no validado**. Viewports Studio no equivalen a prueba móvil real.
- Fixtures solo durante Play. Ambos Places terminaron en Edit; no se publicaron
  desde esa sesión. Persistencia en memoria no demuestra reconexión/teleport.

## 4. Matriz de aceptación pendiente

### A. Feedback de cámara y daño — pendiente de validación

- [ ] Mantener click: shake visible y sostenido; soltar/overheat lo detiene.
- [ ] Pulse, si se habilita: shake por disparo confirmado, sin doble aplicación.
- [ ] No iniciar efectos de disparo en menú, Lobby o countdown.
- [ ] Impactos parciales confirmados activan halo; repetidos renuevan el efecto.
- [ ] Protección sin daño y reset/disminución del porcentaje no generan falso hit.
- [ ] Congelamiento total dispara feedback una vez; respawn limpia todo.
- [ ] Sin deriva acumulada de cámara, sin conflicto con FOV de gancho/zoom.
- [ ] Halo adaptable al viewport, sin bloquear input ni tapar mira.
- [ ] Salida X, W/D, giro de cámara con mouse y reentrada siguen funcionando.

### B. Publicación y multijugador real

- [ ] Publicar ambos Places tras verificar sus versiones y repetir con dos cuentas.
- [ ] Dos grupos 1v1 llegan a reservados distintos; Libre sigue local e independiente.
- [ ] Tercero no entra al stand 1v1 lleno; no duplicar colas ni estados Teleporting.
- [ ] Rechazar lista inválida/duplicada, cupo incorrecto y UserId no autorizado.
- [ ] Countdown 5 s bloquea combate/movimiento; 0g se mantiene entre rondas.
- [ ] Mejor de tres termina al ganar dos; victoria/derrota correctas, empate/cancelación seguros.
- [ ] Avatar real eliminado agarrable durante ronda, sin segundo cuerpo ni autorresurrección.
- [ ] Roster X, colores ocluidos y reset completos; tarjeta víctima visible 3 s.
- [ ] Retorno de todos al mismo Lobby reservado; recuperar fallo de teleport hasta reintentos.
- [ ] Retorno VS avanza misión una vez; reconexión conserva eliminaciones y ranking.
- [ ] Segundo jugador Libre entra aunque otro ya esté activo; dueño de red coincide con servidor.
- [ ] Eliminar/reaparecer en Libre mantiene 0g de supervivientes y salto de quienes están en Lobby.
- [ ] Comparar gancho de ambos clientes con latencia real, energía/VFX y ausencia de duplicados.
- [ ] Validar 2v2–4v4 y cancelación por salida, además de 1v1.

### C. Combate, física y economía

- [ ] Brazo/torso/pierna suman al mismo porcentaje; cabeza x3; eliminación solo a 100.
- [ ] Vaciar stamina sin math.max(nil); soltar/retomar limpia y recrea Beam/VFX.
- [ ] Vidrio decorativo no bloquea; cobertura opaca sí; revisar alcance visual 300 vs servidor 500.
- [ ] Spawn shield cede al disparo válido, no al inválido; orbe azul independiente.
- [ ] Agarre libera root y conserva dirección/intensidad correctas; cuerpos reset dejan de ser agarrables.
- [ ] Power-ups conservan 15 marcadores, no se superponen, rotan puntos y respawn 6 s.
- [ ] Monedas se recogen sin colisión; límite activo y misión de 25 correctos.
- [ ] Dos cuentas compran/equipan ganchos distintos, reconectan y recuperan su propiedad.
- [ ] Recarga comprada persiste al reconectar y viajar Lobby→Match; no refill al equipar cosmético.
- [ ] Pagos por jugar/ganar/eliminar llegan una vez; verificar ruta histórica de recompensa por extremidad.
- [ ] Daily/misiones responden rápido y no permiten doble cobro; logro único persistente.
- [ ] Solo primeros 10 UserId reciben badge QA; repetidos no consumen cupos.
- [ ] Medir carga real de ambos Places antes de optimizar; revisar assets fallidos en Player.
- [ ] Revisión final anti-exploit de remotes y FPS/input/UI en dispositivos de gama baja.

## 5. Roadmap activo

- [ ] Versionado/migración explícita de datos y política final de reinicio de racha.
- [ ] Balance conjunto stamina, gancho, cooldowns y recoil a partir de juego real.
- [ ] VFX/SFX adicionales y onboarding/tutorial.
- [ ] Beneficios de Libre por permanencia y congelamientos.
- [ ] Feedback del portador de cuerpo-escudo; evaluar anclaje trasero/carry y ADS.
- [ ] Puerta de Extracción: definir formatos compatibles/ocupantes distintos antes de implementar.
- [ ] Más coberturas, arenas, cosméticos, objetivos secundarios o segundo modo.
- [ ] Granadas: alcance por definir.
- Campo de tiro/Training: **aplazado por el usuario**.
- Armas de proyectiles: experimento conservado deshabilitado; reactivación no acordada.

## 6. Progreso consolidado

| Etapa | Resultado y decisiones que conservar |
|---|---|
| Sesiones 1–4 | MVP R15, fuerzas 0g, beam/arma procedural, Freeze por personaje/dummies, poses swim/procedural |
| Sesiones 5–9 | Agarre E, corrección de script mal ubicado y jitter, cuerpos-escudo; ADS/carry propuestos |
| Sesiones 10–13 | Perfil/daily/misiones, energía y cosméticos de gancho, resultados/MVP, beam continuo y overheat |
| Sesiones 14–18 | Prototipo MatchRegistry y arenas clonadas, estado por jugador; posteriormente sustituido |
| Sesiones 19–23 | Lobby/Match separados con PlaceConfig y teleport; Libre finalmente queda local |
| Sesiones 24–27 / 2026-09-02 | Diagnóstico gravedad, uniones, eliminaciones, resultado, retorno, misiones y monedas |
| Sesiones 28–29 / 2026-09-07 | Stands, cuenta de cola, HUD/daily, compensación individual Libre, tres power-ups/15 puntos |
| Sesión 30 / 2026-09-09 | Cupo exacto autorizado, mejor de tres, countdown 5 s, HUD VS y retorno grupal |
| Sesiones 31–32 / 2026-09-11 | Entrada del segundo cliente, transición dirigida, feedback de víctima, inicio local del gancho |
| Sesiones 33–36 / 2026-09-14 | Remotes asíncronos sin InvokeServer, HUD cacheado, CombatActive, ranking no bloqueante; estabilidad validada en producción |
| Sesiones 37–39 | FullFreeze y placas reactivas, daily sin bloqueo, paridad feedback Lobby/Match |
| Sesiones 40–41 | Importación de Package de proyectiles y posterior desactivación; beam restaurado como único activo |
| Sesiones 42–44 | Impulso inverso E, daño beam ×4 hasta 18/14.4/36, persistencia gancho y ranking corregidos |
| Sesión 45 / 2026-09-16 | Mochila, tienda por prompt, badge de 10, gancho fuerza 1000/velocidad 70/FOV +11 |
| Sesión 46 / 2026-09-21 | IK de apuntado, respawn Libre protegido dentro de arena, mochila Match, mira -110 y alcance local 300 |
| Sesión 47 / 2026-09-30 | CombatFeedback, ragdoll reversible, roster X, escudos separados, recarga de tienda, EquipmentDashboard y corrección de orientación Lobby |
| 2026-10-02 | Documentación consolidada en cuatro páginas; shake/halo reforzados en Lobby y Match; overlay comprobado en Play, combate manual pendiente |

### Procedencia de la consolidación

- REGLAS integra `ReglasRoblox.md` y la referencia GUI de `SKILL.md`.
- DISENO integra resumen, disparo/congelamiento, captura, arquitectura de Places,
  estructura, reemplazos y contratos de combate/UI.
- CHECKLIST integra ruta, verificaciones del sprint y progreso diario resumido.
- BUGS integra incidentes de producción y correcciones descritas en la bitácora/sprint.
- Matchmaking por arenas clonadas se conserva como decisión histórica sustituida,
  no como instrucciones activas.
- Se preservaron los cambios locales existentes al extraer su contenido; la
  eliminación previa de `UI_ASSET_SPEC.md` no se revirtió. No se creó un commit.
