# ZERO BREACH — Plan de entrega de 10 días

Creado: 2026-10-08. Fecha de entrega asumida: **20 de octubre de 2026**.
Sprint: **11–20 de octubre**, diez días naturales, incluida la entrega.
Base: [CHECKLIST](CHECKLIST.md), [BUGS](BUGS.md) y [SUGERENCIAS](SUGERENCIAS.md).
Este documento planifica trabajo; no certifica correcciones ni implementaciones.

## Replanificación vigente — 19/10/2026: beta y extensión solicitada

**Decisión del usuario:** mantener la entrega del **20/10** como contingencia,
con alcance beta y prioridad a reducir errores. Solicitar **al menos 7 días más**.
La extensión **no está confirmada**: la fecha propuesta sería el **27/10/2026**
(21–27/10, siete días adicionales). No desplazar la entrega original hasta recibir
confirmación. El calendario original de diez días se conserva abajo como referencia;
esta sección define el orden de trabajo actual.

**Ajuste de prioridades confirmado por el usuario:** trabajar **hoy 19/10 y mañana
20/10 en móvil**, incluidos los cambios de interfaz/assets que resulten necesarios,
y probar el recorrido principal en esos dispositivos. Proponer colección premium,
capa global y video para la extensión. **Anuncios:** el usuario informa que la
experiencia aún no alcanza la elegibilidad por su cantidad de jugadores activos;
no comprometer su activación para el 20/10 ni para el 27/10. La elegibilidad queda
pendiente de comprobación en el Dashboard para la modalidad elegida. El informe
puede prepararse durante la extensión; activar anuncios requiere cumplir los
requisitos correspondientes, no solamente disponer de siete días adicionales.

**Avance móvil 19/10:** Up/Down retirados; Fire/Hook ampliados con aspecto circular;
arrastre de disparo conectado a la cámara y botón contextual IMPULSO para liberar
agarre. Cambios compartidos en ambos Places. QA controlada/simulador pasa para
fire+arrastre, segundo gesto, liberación con velocidad 90 y cancelación por menú;
capturas iPhone 17 Pro/Galaxy A06. El teléfono físico, agarre iniciado por tap real
y partidas publicadas siguen siendo el siguiente cierre de hoy/mañana. No dar
por aceptado móvil solo por el simulador; detalles en CHECKLIST y BUGS B21/B22.

### Corte real del alcance

| Área | Evidencia disponible | Qué falta para aceptarla |
|---|---|---|
| Libre / VS / gancho / agarre / respawn | Implementaciones y correcciones registradas; el usuario reportó funcionamiento del flujo principal en una versión anterior. | Repetir con versiones actuales publicadas, dos cuentas en combate y una tercera en Lobby; cubrir 1v1 y 2v2 antes de aceptar esos formatos. |
| Guardado, misiones, calendario y ranking | B11/B16/B20 con QA de Studio; historial diario y deduplicación documentados. | Reconexión y teleport reales, cambio de día UTC, pagos únicos y estadísticas por encuentro completo. |
| Armas y monetización | Pase del Cañón conectado; inspección del Lobby el 19/10: `PassId=2039918698`, integración activa y `AutoGrantPasses=true`. Rifle: `PassId=0`, integración inactiva. | Compra/cancelación con cuenta sin pase y conservación de derechos al viajar/reconectar; auditar paridad del catálogo y derechos en Match. No confundir al creador con una cuenta sin pase. |
| Presentación / onboarding | Manual de inicio con placa completa y botón ENTENDIDO de imagen, adaptado a escritorio/móvil; carteles de ganchos con imágenes/E; flotantes de estado de armas retirados; hologramas y animación retirados; BillboardGui a 20 studs. Cinco imágenes de láser completas y nuevo aviso de protección en ambos Places. | QA publicada y touch real; arte del manual aplicado. El texto del manual quedó dentro de la placa: cambios de controles requieren nueva imagen. Aviso enlazado al escudo existente sin cambiar inmunidad. |
| Congelamiento azul | `FreezeAppearance` y cuerpo Ice aplicados en ambos Places; QA controlada R15 de parcial, total y restauración, 15 partes corporales por Place. | Impactos entre jugadores reales, visibilidad remota y ciclo completo de ronda/respawn. |
| Cartelera de Libre | `AnimationIconSign`: cuatro eventos recientes con fotos/nombres/cruz; QA de presentación con datos simulados. | Acreditación con congelamientos reales y varios jugadores. |
| Colección premium completa, capa global y video | El plan original los exige; esta revisión no aporta evidencia suficiente para darlos por terminados. El usuario propone pasarlos a la extensión. | Acordar alcance y completar contenido, IDs, permisos y distribución. Su entrega depende de la extensión y de las aprobaciones externas correspondientes. |
| Anuncios e informe | El usuario informa elegibilidad pendiente por falta de jugadores activos suficientes; no se comprobó un umbral ni una modalidad en esta revisión. | Preparar informe y revisar requisitos/Dashboard durante la extensión. La activación queda para cuando la experiencia sea elegible y haya presupuesto/decisión, sin fecha prometida. |

**No hay un porcentaje de avance verificable:** implementación, prueba Studio y
aceptación publicada son estados distintos. La beta propuesta es una reducción
del alcance original; comunicarla junto a sus pendientes, sin declararla final.

### Hoy 19/10 — candidata y pruebas prioritarias

1. Revisar móvil real: distribución y tamaño de controles, disparo+gancho,
   apuntado, menús, scroll, salida, orientación, zonas seguras y legibilidad.
   Registrar los fallos y aplicar los cambios de UI/assets necesarios hoy y mañana.
2. Mantener el resto del alcance estable. Respaldar las versiones actuales de
   Lobby y Match; registrar versión, configuración e IDs. Preparar la candidata
   de ambos Places y coordinar la publicación para QA.
   La prueba válida de VS se inicia por la cola del Lobby; Play aislado de Match
   sin TeleportData no comprueba teleport ni una partida completa.
3. Con tres cuentas A/B/C: C permanece en Lobby; A/B juegan Libre y VS 1v1,
   completan un encuentro, vuelven al mismo servidor que C y repiten con abandono.
   Anotar saldo, equipado, victorias/partidas y misiones antes y después.
4. Reconectar A; comprobar guardado, propiedad y cobros únicos. Repetir dos entradas
   VS para las barreras de spawn B19. Probar agarre de cuerpo y liberación al reset.
5. Probar 2v2 con cuatro cuentas si se incluye en la beta. Repetir el recorrido
   en móvil tras cada cambio relevante de controles/UI/assets y clasificar fallos
   por impacto. El simulador sirve para layout; la aceptación táctil es en teléfono.
6. Corregir primero los casos fallidos y repetirlos; el pulido visual restante no
   desplaza pérdidas de datos, bloqueos de partida o errores de compras.

### Mañana 20/10 — decisión de entrega

Completar los ajustes móviles y de UI/assets iniciados el 19/10; repetir controles,
menús y combate en teléfono real y hacer una comprobación breve en escritorio para
evitar regresiones. Es el bloque principal de trabajo de ambos días. Colección
premium, capa global, video y activación de anuncios no compiten por estas horas.

**Beta candidata:** Lobby, Libre y formatos VS efectivamente comprobados, combate,
gancho/agarre, respawn/salida, inventario y economía existente, con lista de
limitaciones y canal de reportes. No prometer funcionalidades externas sin entregar.

Antes de abrir la beta:

- [ ] Registrar versiones publicadas de ambos Places y probar en servidores nuevos.
- [ ] Entrada, combate, congelamiento azul, reset/respawn y salida utilizables.
- [ ] VS termina o se anula correctamente; grupo retorna junto, sin quedar atrapado.
- [ ] Reconexión/teleport conservan saldo, propiedad y selección, sin duplicar pagos.
- [ ] Resultados y misiones no cuentan rondas/anulaciones como encuentros completos.
- [ ] Compras ofrecidas verificadas con una cuenta sin propiedad; no activar ventas
  nuevas cuyo derecho, precio o entrega no estén probados.
- [ ] Dispositivos objetivo pueden jugar; controles y assets críticos cargan.
- [ ] Preparar notas beta, pendientes conocidos, contacto de soporte y reversión.

**Criterio de salida:** no publicar una beta abierta con fallos conocidos de pérdida
de datos, cobros/entregas incorrectos, bloqueo del recorrido principal o imposibilidad
de jugar en los dispositivos anunciados. “Beta” permite pendientes de contenido o
pulido; no sustituye esos mínimos. Si no se cumplen, entregar estado y candidata
de acceso limitado para revisión, junto con los bloqueos pendientes.

Si la extensión no llega, entregar el alcance beta acordado el 20/10 y proponer
updates pequeños después, con fechas comunicadas según capacidad real. Si se
aprueba, usar la semana para cerrar aceptación, no para ampliar modos o balance.

### Semana adicional propuesta — solo si se aprueba

| Fecha | Prioridad | Cierre verificable |
|---|---|---|
| 21/10 | Datos, misiones, calendario y ranking. | Reconexión, cambio de día UTC y teleport conservan datos; premios y resultado se acreditan una vez. |
| 22/10 | Libre, 1v1, 2v2, retorno y regresiones de cuerpos/barreras. | Casos reales con grupo, abandono, dos entradas y observador remoto; registrar qué formatos pasan. |
| 23/10 | Seguimiento de móvil, carga, permisos y rendimiento. | Revalidar los ajustes trabajados el 19–20/10, ampliar dispositivos y medir carga/FPS; no aplazar el primer trabajo móvil hasta esta fecha. |
| 24/10 | Tienda, derechos Robux y paridad Lobby/Match. | Compra/cancelación con tester sin pase; equipado/propiedad tras reconexión y viaje. Rifle solo si ID, precio y QA están resueltos. |
| 25/10 | Colección premium, capa global, video e informe de anuncios propuestos para la extensión. | Entregar lo aprobado y disponible; registrar bloqueos externos. Revisar elegibilidad publicitaria y preparar informe, sin comprometer activación mientras no se cumplan los requisitos. |
| 26/10 | Regresión integral y correcciones finales. | Candidata con evidencia por caso y sin bloqueantes; repetir únicamente fallos o áreas afectadas por nuevos cambios. |
| 27/10 | Entrega revisada, si la extensión fue confirmada. | Versiones, smoke test Player, evidencia, notas y reversión; pendientes externos explicitados y acordados, sin etiquetarlos terminados. |

Preparar desde hoy los assets y datos externos que requieran revisión; el 25/10
no es una garantía de aprobación de la capa global o del video. La capa solicitada
sigue siendo de inventario global de Roblox; no cambiarla por un accesorio interno
sin acordarlo con el usuario.

La activación publicitaria queda fuera de una fecha cerrada mientras falte
elegibilidad. Registrar modalidad, requisitos oficiales vigentes, estado del
Dashboard y próxima revisión; no inventar un número mínimo de jugadores ni asumir
que todas las modalidades publicitarias tienen los mismos requisitos.

### Texto sugerido para solicitar la extensión

> Solicitamos ampliar la entrega del 20 al 27 de octubre para completar la colección
> premium, la capa global y el video, además de cerrar las validaciones pendientes
> de juego, datos y compras. Hoy y mañana priorizamos la adaptación móvil y los
> ajustes necesarios de interfaz/assets. Como contingencia para el día 20 proponemos
> una beta de alcance reducido y probado, con limitaciones y actualizaciones
> documentadas. La ampliación está sujeta a confirmación. La activación de anuncios
> queda condicionada a alcanzar la elegibilidad de la experiencia; durante la
> extensión podemos preparar el informe y revisar los requisitos, sin prometer su
> activación para una fecha que no depende solo del desarrollo.

---

## Plan original del sprint (referencia de alcance)

## Objetivo de entrega

- Misiones diarias actualizadas, progreso correcto y cobro persistente sin duplicados.
- Ranking que contabilice partidas según una regla definida, además de revisar victorias y eliminaciones.
- Una colección premium completa: skin de arma, cuerda, punta de gancho y personaje, comprable con Robux.
- Una **capa gratuita como accesorio de avatar**, adquirida mediante el flujo oficial
  de Roblox y conservada en el **inventario global del jugador**. Confirmado por el usuario.
- Video del juego reproducible en el Lobby.
- Investigación de anuncios con decisión, requisitos, coste y propuesta de campaña.
- Lobby y Match publicados y probados con cuentas reales, en escritorio y móvil.

## Alcance y decisiones para evitar retrasos

1. **Cosméticos:** entregar primero una colección de cuatro elementos. Las tres
   colecciones de SUGERENCIAS son propuestas, no un requisito de este sprint.
   Usar un pase permanente para el pack inicial; confirmar precio y contenido.
   Cuerdas actuales son Beams: necesitan diseño visual, no necesariamente un modelo 3D.
2. **Capa global — confirmado:** el jugador debe conservarla en su inventario de
   Roblox. Modelar y ajustar el accesorio al avatar; validar la categoría y la
   modalidad de distribución gratuita admitidas, elegibilidad del creador,
   presupuesto por unidades, stock y moderación en el Dashboard. Iniciar el trámite
   el día 1 y revisar su viabilidad el día 3. Conectar reclamación mediante el prompt
   oficial y verificar propiedad después de la adquisición. Un Accessory local o
   un registro en DataStore no cumplen esta entrega. Si hay un bloqueo externo,
   registrarlo y acordar la solución con el usuario; no sustituirla por una capa
   exclusiva del juego sin su aprobación.
3. **Partidas:** definir qué cuenta como partida terminada, cómo tratar abandono,
   empate y cancelación, y si Libre participa en esa métrica. Libre no tiene el
   mismo ciclo de fin que VS: entrar o reaparecer no debe convertirse accidentalmente
   en una partida completada. Compartir la regla entre misiones y ranking.
4. **Video/anuncios:** preparar video propio y estudiar por separado publicidad
   para atraer jugadores, anuncios inmersivos y anuncios recompensados. El video
   propio no genera ingresos publicitarios por sí solo. La investigación de anuncios
   sí entra en la entrega; su activación depende de elegibilidad y presupuesto.

## Calendario

| Día | Fecha | Trabajo principal | Resultado exigido al cerrar el día |
|---|---|---|---|
| 1 | 11/10 | Reproducir fallos de misiones y ranking; registrar estado en ambos Places. Definir cómputo de partidas y colección/precio. Revisar publicación y distribución gratuita de la capa global, video y anuncios; comenzar modelado y trámites externos. | Bugs reproducibles, reglas escritas, responsables asignados, presupuesto y ruta de publicación de la capa definidos. |
| 2 | 12/10 | Corregir misiones: cambio de día, progreso por eventos reales, refresco de UI, reclamación y guardado. Separar misión diaria de recompensa de inicio de sesión. | Cambio de día comprobado con reloj de prueba controlado, sesión abierta y reconexión; una recompensa por reclamación. |
| 3 | 13/10 | Corregir contador/ranking de partidas, victorias y eliminaciones. Deduplicar resultados por identificador de partida y resolver actualización entre Lobby y Match. Revisar viabilidad de capa global. | Una partida VS real incrementa lo esperado una vez; rondas, retorno y reconexión no duplican; ranking conserva datos. |
| 4 | 14/10 | Integrar modelos de arma, gancho y personaje, diseño de cuerda, capa y miniaturas. Ajustar pivotes, escala, montaje, materiales y comportamiento con R15. | Colección completa y capa visibles sin colisiones extra ni cambios de balance; otro jugador puede verlas. |
| 5 | 15/10 | Conectar pase de Robux, derechos en servidor, catálogo, tienda, inventario y selección persistente. Replicar integración en Lobby y Match. | Compra/desbloqueo, cancelación, reentrada y teleport verificados; equipado sin recuperar energía ni duplicar visuales. |
| 6 | 16/10 | Conectar reclamación oficial de la capa global y verificar adquisición, propiedad y equipado; comprobar stock y estado agotado. Grabar/editar tráiler de 15–30 s; iniciar subida y revisión del video en cuanto esté listo. Cerrar informe de anuncios. | Capa adquirible gratis y comprobada en el inventario de Roblox si ya está aprobada; video enviado o disponible; informe con opciones, elegibilidad, presupuesto y métricas. |
| 7 | 17/10 | Montar pantalla de video y verificar permisos/reproducción. Validar en Player el fix B18 de ZB_Intro, cerrado en Studio el 13/10; revisar manual, tienda, actividades y touch. Cerrar regresiones de apuntado, cámara, respawn y salida. | Video probado en Player si ya está aprobado; interfaz y controles utilizables en escritorio y móvil; pendientes externos visibles. |
| 8 | 18/10 | Prueba integral publicada con al menos dos cuentas: Libre, VS 1v1 y equipos 2v2–4v4, colas, rondas, resultados, retorno y persistencia. | Registro de casos con evidencia; lista final de fallos por gravedad. Congelar funcionalidades nuevas. |
| 9 | 19/10 | Reserva para corregir bloqueantes, repetir casos fallidos, comprobar FPS/carga/assets y preparar versión candidata con respaldo. | Candidata sin fallos bloqueantes; ambos Places y configuración premium coinciden; contingencias externas acordadas. |
| 10 | 20/10 | Publicar versión final y hacer smoke test en Roblox Player: entrar, completar partida, consultar ranking, reclamar/equipar y reproducir video. Preparar entrega. | Versión y enlaces registrados, checklist de aceptación, IDs/precios, evidencia y procedimiento de reversión entregados. |

**Trabajo paralelo necesario:** mientras se corrigen sistemas los días 1–3,
arte debe preparar los cosméticos y la capa. El video necesita material de juego
desde el inicio. No esperar al día 6 para revisar permisos de subida o al día 8
para conseguir cuentas/dispositivos de prueba.

## Pruebas obligatorias para cerrar la entrega

### Misiones y ranking

- [ ] Misiones se renuevan al cambiar el día sin exigir cerrar el juego; definir zona horaria y mostrar próximo reinicio.
  **B11: corregido y verificado en Studio el 09/10**, con reinicio 00:00 UTC y
  cuenta atrás visible; falta validación publicada para cerrar esta aceptación.
- [ ] Progreso coincide con acciones reales y con la definición de partida acordada.
- [ ] Pulsaciones repetidas, reconexión y fallo de guardado no duplican recompensas.
- [ ] VS cuenta una partida completa, no cada ronda; abandono/empate/cancelación siguen la regla acordada.
- [ ] Ranking refleja datos actuales dentro del intervalo de refresco definido, conserva totales y no mezcla partidas.
- [ ] Revisar jugadores existentes: determinar si los datos históricos permiten reparar contadores; documentar límites si no se puede reconstruir el pasado.

### Robux, skins y capa

- [ ] Catálogo muestra precio vigente y contenido exacto; compra validada por servidor.
- [ ] Comprar, cancelar y volver a entrar producen el estado correcto; presupuestar cualquier compra real de QA.
- [ ] Derechos y selección se recuperan tras reconexión y Lobby→Match→Lobby.
- [ ] Jugador sin propiedad no equipa premium mediante remotes ni compra con monedas.
- [ ] Skins visibles para otros jugadores; apuntado, Muzzle, gancho y ragdoll siguen correctos.
- [ ] Capa no altera colisiones/combate; respawn y reentrada no crean duplicados.
- [ ] Capa global: adquisición oficial gratuita y propiedad verificadas en el inventario web/Avatar Editor de Roblox; comprobar equipado en otro entorno compatible.
- [ ] Stock y estado agotado verificados. No presentar reventa paga como regalo ni prometer unidades ilimitadas si el artículo tiene cupo.

### Juego completo y publicación

- [ ] Libre: dos participantes y uno en Lobby; eliminación no cambia la gravedad de los demás, respawn protegido y salida/reentrada correctos.
- [ ] VS: colas/cupos, reservados separados, countdown, mejor de tres, roster, resultado y retorno grupal.
- [ ] Combate: impactos/escudos, shake/halo, energía, gancho, agarre, cámara, rigs y reset/ragdoll.
- [ ] Economía existente: monedas, recarga, recompensas y guardado al cerrar/reconectar sin duplicados.
- [ ] Móvil real: touch, menús, orientación acordada y desempeño; escritorio: mouse, foco/chat y cursor al salir.
- [ ] Assets/audio/video cargan con permisos correctos; medir carga y FPS en dispositivo objetivo.
- [ ] Servidor valida acciones/recompensas y mantiene límites de remotes; sin errores bloqueantes de arranque.

## Entregables del estudio de anuncios

- Comparación: campañas de adquisición, anuncios inmersivos y anuncios recompensados.
- Elegibilidad comprobada de cuenta/experiencia y fecha de consulta oficial.
- Costes actuales, presupuesto propuesto, duración, creativo y destino Lobby.
- Métricas: coste por jugador, retención y conversión; ingresos estimados solo con evidencia.
- Recomendación explícita: activar, preparar o posponer cada modalidad.
- Si se eligen anuncios recompensados posteriormente: ampliar alcance para producto,
  recibos idempotentes y QA; no improvisar entrega mediante temporizadores.

## Prioridades y control diario

### Avance del día 5 — 2026-10-16: pase del Cañón conectado

- Responsable: asistente mediante MCP. Lobby `125075465377023`; Match
  `108298899371591` recibió la conservación del derecho en su DataService.
- Terminado: pase `2039918698` ("cañon", 10 R$) conectado. `MonetizationService`
  verifica `UserOwnsGamePassAsync`, concede el Cañón sin cobrar monedas, registra
  `profile.passes` y guarda; concede tras `PromptGamePassPurchaseFinished`. El
  Cañón es **solo con el pase** (se quitó la compra de 250 monedas). La tienda
  muestra DESBLOQUEAR · 10 R$ y abre el prompt; el cliente no prueba propiedad.
- QA Studio: con el pase, concede y equipa el Cañón (500 monedas intactas,
  `passes={"2039918698":true}`); sin el pase (servicio desactivado solo para
  observar), tarjeta DESBLOQUEAR · 10 R$; comprar con monedas un arma de pase
  rechazado sin cobro ("se desbloquea con su pase"). Sin errores de scripts.
- Reset pre-lanzamiento: `WeaponPassReset` quita una vez el Cañón de los testers
  y limpia `passes` para poder probar la compra (idempotente; subir `VERSION` para
  repetir). No toca otras armas.
- Diagnóstico "todos tienen el Cañón": `UserOwnsGamePassAsync` devuelve true para
  la cuenta creadora del pase y false para otras; en Studio multijugador todos son
  la misma cuenta. Se agregó `ReplicatedStorage.Monetization.AutoGrantPasses`
  (hoy false) para no conceder al entrar; **poner true antes de lanzar**. Compra
  real se prueba con una cuenta tester sin el pase.
- Respaldo `ZB_CannonPassBackup_20261016`; rutas y QA en UI_ASSETS 0.5.
- Pendientes: compra real con Robux, segundo jugador sin pase, cancelación/
  reconexión y viaje Lobby→Match→Lobby publicados; crear el pase del Rifle.
  Esto cubre el pase del Cañón del día 5, no la colección ni la capa del día 6.

### Avance del día 6 — 2026-10-16: imágenes y showroom de armas

**Avance posterior — historial y colores del calendario (B20):** las fechas ahora
se pintan verde (cobrado), rojo (pasado sin cobrar), ámbar (disponible) o gris
(sin datos/futuro). Nuevo `ServerScriptService.DailyClaimHistory`; `daily` guarda
`claimedDays`/`historyStartDay`. DailyRewardService acredita saldo y fecha juntos;
DataService de ambos Places preserva el historial. Días previos al registro quedan
gris "sin datos" (no se inventa historial). QA con reloj de prueba: migración,
500→550→600, día intermedio en rojo, repetidas sin doble pago, guardado preserva
3 fechas. Respaldo `ZB_DailyHistoryBackup_20261016`; edición en UI_ASSETS 0.7 y
B20. Sin publicar; falta medianoche/reconexión reales. Esto adelanta la validación
de misiones/calendario, no cierra el ranking ni el bloque completo del día 2–3.

**Avance posterior del mismo día — cable genérico:** una apariencia 3D opaca,
cilíndrica y editable del gancho, con refuerzos, sincronizada en Lobby y Match.
El usuario aclaró que Navidad era solo un ejemplo; no se crearon consumibles,
inventario nuevo ni mecánicas de cuerda. Control/fuerza/energía intactos. QA de
gancho controlado en Libre y fixtures visuales en ambos Places; edición y límites
en UI_ASSETS 0.6. Respaldo `ZB_GenericHookRopeBackup_20261016`. Match se conectó para
esta parte; la sincronización de las imágenes/UI del showroom anterior sigue
pendiente. Sin publicación ni aceptación multicuenta/touch/FPS.

- Responsable: asistente mediante MCP. Lobby `125075465377023` conectado; Match
  `108298899371591` cerrado/no disponible para esta sesión.
- Terminado: tres imágenes propias de armas recortadas/subidas/aplicadas y tres
  vitrinas clonadas del contenedor de ganchos, con armas estáticas, carteles y E.
  Vitrinas y tienda abren la misma ficha con foco/scroll. SDR-Mk2 gratis; Rifle y
  Cañón con Pase próximamente, catálogo WeaponOffers con PassId=0.
- QA Studio: imágenes 3/3 cargadas; E en las tres vitrinas; saldo 500 intacto y
  sin equipado/cobro por tarjeta pendiente. Respawn mantiene una GUI, tres vitrinas,
  tres prompts y 38 piezas ancladas. Capturas desktop y móvil horizontal, sin touch
  físico. Fuentes de ganchos preservadas. Lobby en Edit/default; sin publicar.
- Respaldo `ZB_WeaponShowroomBackup_20261016`; IDs/rutas en UI_ASSETS 0.4–0.5.
- Siguiente acción: abrir Match para sincronizar imágenes/catálogo/dashboard;
  crear los dos pases y conectar compra/derechos de servidor del día 5. Este avance
  visual no cierra monetización, capa global, video ni informe de anuncios del día 6.

### Corte del día 4 — 2026-10-14

**Modelos de armas integrados:** SM_Wep_SMG_01 reemplaza el visual de `rifle` y
SM_Wep_Laser_Gun_01 el de `cannon` en ambos Places; SDR-Mk2 sigue como base gratuita.
Revisión posterior de la captura del usuario: frente/agarre del Rifle corregido,
ambos modelos +15 % y tarjetas con espacios de imagen propios (UI_ASSETS 0.4).
Respaldo adicional `ZB_WeaponPresentationBackup_20261014`; PNG reales pendientes.
Montaje R15, Muzzle/beam, cambios repetidos y respawn comprobados en Studio.
Estadísticas y compra con monedas existentes conservadas; venta Robux pendiente
del día 5. Respaldo `ZB_WeaponModelsBackup_20261014`; contrato/evidencia en DISENO.
Este avance cubre modelos de armas, no la colección completa de gancho/personaje/capa.

**Regresión reportada y corregida — B19:** segunda entrada 1v1 con escudos Azul/Rojo
flotando. MatchArenaPhysics desanclaba las barreras `SpawnCover=true` por compartir
el atributo de agarre `cubrirce`. Guard añadido exclusivamente en Match; dos
arranques Studio con las diez piezas ancladas y desplazamiento cero tras impulsos.
Respaldo `ZB_SpawnCoverBackup_20261014`; evidencia en BUGS/CHECKLIST. Sin publicar;
repetir la secuencia de dos entradas reales tras publicar Match sigue pendiente.

**Avance visual adicional de hoy:** postprocesado azul/violeta, sombras
desactivadas y animación de monedas al acreditar congelamientos completos,
con dispersión/Tween al contador ahora visible en combate. Plantilla editable
`StarterGui.ZB_CoinFeedback`, guía en UI_ASSETS (0.3) y valores en luces.md.
QA Studio controlada desktop/móvil en ambos Places; no validada aún con un
congelamiento real publicado. Respaldo `ZB_VisualFeedbackBackup_20261014`;
sin publicación. No equivale a integrar el pack premium del día 4.

**Reporte del usuario de hoy:** una prueba con cuentas funcionó y por ahora la
considera OK; quiere continuar repitiendo. No se especificaron versiones,
resultados por caso ni evidencia de cada contador/retorno. Registrar ese avance
sin marcar toda la aceptación B15/B16 ni persistencia como definitivamente cerrada.

**Cerrado hoy en implementación y QA visual Studio:** accesos del HUD editables
en StarterGui en Lobby y Match, mayor padding/separación, retirada de la opción
obsoleta «No entrar a la próxima batalla» y guía actualizada en UI_ASSETS (0.2).
Capturas desktop/móvil horizontal en ambos Places; B/Tab/Alt en Lobby mediante
fixture visual local. Sin publicación; no equivale a validar touch ni teleport.
Responsable: asistente mediante MCP. Respaldo de controladores y layout móvil:
`ServerStorage.ZB_HudEditableBackup_20261014`. Adelanta parte del día 7.

**El día 4 completo sigue abierto:** SDR-Mk2 como arma base y los atlas UI no
constituyen la colección premium de arma/cuerda/punta/personaje ni la capa global.
La integración completa requiere identificar/aprobar los assets y comprobar su
montaje R15 y visibilidad desde otra cuenta. La viabilidad/publicación de la capa
global sigue sin evidencia de Dashboard en este registro.

**Orden recomendado para cerrar trabajo adicional hoy:**

1. Inventariar assets de la colección inicial en ambos Places y registrar qué
   existe, qué falta y su ruta; confirmar estética/contenido antes de integrarlos.
   Cerrar la preparación del catálogo y los contratos de montaje que se puedan
   comprobar en Studio; no marcar la colección completa solo por el inventario.
2. Validar B15/B16 con tres cuentas en Player después de publicar ambos Places:
   A/B completan VS, C permanece en Lobby; retorno al Job de C, resultado una vez,
   ranking/misión/saldo y conservación por reconexión. Repetir anulación sin premio.
   Este bloque permite cerrar aceptación pendiente del día 3 si pasa.
3. Resolver los datos externos que condicionan los días 5–6: precio/propietario/ID
   del pase y, para la capa, categoría, elegibilidad, stock/coste y ruta gratuita
   oficial. Registrar decisiones confirmadas y evidencia; no asumir aprobación.

No se ejecutaron nuevas pruebas de resultados/persistencia ni se creó el pack
premium al revisar este corte. Misiones, ranking y QA publicada conservan sus
casillas pendientes hasta que haya evidencia.

**Bloqueantes:** pérdida/duplicación de datos o compras, partidas sin terminar,
misiones/ranking incorrectos, imposibilidad de entrar/salir o jugar en dispositivos objetivo.
Se corrigen antes de publicar la final.

**Dentro del sprint:** colección inicial, capa, video, informe de anuncios y QA anterior.
**Después del día 20:** colecciones adicionales, migración completa de pantallas,
modos/arenas/granadas nuevos, Training y mejoras de balance no necesarias para cerrar bugs.
El roadmap completo de CHECKLIST queda como backlog, no como compromiso de diez días.

Al terminar cada día registrar: responsable, terminado, prueba realizada, bloqueo,
siguiente acción y Place/version afectados. Marcar listo solo después de probar.
Preparar copias/versiones de Lobby y Match antes de cambios críticos y publicación.

### Fix cerrado — B18: espera bloqueante de ZB_Intro, 2026-10-13

- [x] **Corrección y QA Studio cerradas en Lobby y Match.** AtlasUIController
  inicia sin esperar el manual y lo enlaza por eventos cuando aparece.
- [x] Verificado inicio sin manual, llegada tardía, apertura/cierre con mouse,
  bloqueo de input durante el menú y respawn con un solo manual/acceso de ayuda.
- [x] Fuentes iguales y compiladas en ambos Places; nuevo arranque sin aviso de
  espera de ZB_Intro. Respaldo: `ServerStorage.ZB_GrabHookBackup_20261013`.
- [ ] **Aceptación publicada:** publicar ambos Places y repetir ayuda→Continue
  y respawn en Roblox Player, incluido touch. Sin versión publicada en esta sesión.

Responsable: asistente mediante MCP. Evidencia detallada en [BUGS, B18](BUGS.md).
El día 7 conserva la validación publicada; la corrección de esta espera ya está terminada.

### Registro previo al sprint — 2026-10-09

- Responsable: asistente mediante MCP. Leída la documentación completa y aplicada
  la primera etapa solicitada por [luces.md](luces.md), en Lobby y Match.
- Terminado en Studio: auditoría, respaldo de Lighting, iluminación global y
  postprocesado moderado; capturas antes/después y smoke test de arranque.
- Prueba: efectos únicos en ambos clientes; Continue y W en Lobby; gravedad
  conservada; firma de Workspace coincide. Ambos Places quedan en Edit, sin publicar.
- Pendiente externo/QA: imagen de referencia no adjunta; FPS, móvil y combate
  publicado todavía sin validar. Esto no cierra las pruebas obligatorias del sprint.
- Siguiente acción de código: reproducir renovación/cobro de misiones y contador
  de ranking; acordar cómputo VS/Libre antes de cambiar sus recompensas.
- Valores originales, finales y reversión: luces.md y
  `ServerStorage.ZB_LightingBackup_20261009` de cada Place. No se registró versión publicada.

## Decisiones que el equipo debe confirmar al iniciar

### Avance del día 3 — 2026-10-13: prioridad al agarre reportado

- Responsable: asistente mediante MCP; Lobby `125075465377023` y Match
  `108298899371591`, tratados como partes del mismo juego.
- Terminado: **B17**, permitir agarre voluntario durante gancho, relevo de tracción
  sin borrar impulso y seguimiento/limpieza de prompts. **B18**, eliminar espera
  bloqueante de ZB_Intro y enlazar el manual por eventos.
- Prueba: disponibilidad de prompts 61/58 durante gancho; bloqueo y recuperación
  de UI/countdown; funciones exactas de relevo/soltar/cancelar con transporte
  simulado. Manual tardío, clicks reales y respawn sin duplicados en ambos Places.
- Estado: cerrados en implementación/QA controlada Studio, **no en producción**.
  Fuentes compartidas iguales, compiladas, sin fixtures; ambos Places en Edit.
  Respaldo `ServerStorage.ZB_GrabHookBackup_20261013`; evidencia y límites en BUGS.
- Siguiente acción: publicar ambos Places y probar trayecto real con gancho→E→soltar,
  cobertura móvil, escudo de cuerpo B13 y touch. El intento Q/E con fixture no
  certificó el trayecto físico. Probar retorno/ranking con tres cuentas y
  reconexión sigue pendiente; estos cambios no cierran B15/B16 ni las aceptaciones
  de persistencia del día 3. No se registró nueva versión publicada.

### Avance de arte UI — 2026-10-13

- Terminado en ambos Places: integración de los tres atlas entregados, con 16
  iconos Fit, 8 estados de botones y 4 marcos 9-slice. Recortes/IDs en assets/ui;
  damero pintado retirado, texto separado y esquinas protegidas contra estiramiento.
- Prueba: 28/28 recursos cargados por cliente, escritorio y simulador iPhone 17 Pro,
  contraste, selección/presión, tamaños variados y respawn sin duplicados.
- Respaldo `ServerStorage.ZB_UIAtlasBackup_20261013`; detalle en UI_ASSETS.
  Ambos Places en Edit y simulador default; sin publicación. Adelanta presentación
  de interfaz del día 7; no sustituye colección premium del día 4 ni QA touch real.

**Reporte publicado y revisión posterior 09/10:** usuario valida calendario,
arma/apuntado remoto, Libre y flujo principal de VS. Reporta agarre/etiqueta,
pasos en 0g, retorno que separa del origen y contadores VS. Se implementaron B13–B16
en ambos Places, con QA Studio y respaldo; publicar/repetir con tres cuentas sigue
pendiente. Métrica elegida con decisión delegada: **VICTORIAS VS** por encuentro
completo; tabla **CONGELADOS MODO LIBRE**. No contabilizar rondas ni anulaciones
como encuentros completos. Detalle y límites de persistencia/histórico en BUGS.

**Avance adicional 09/10:** calendario mensual real y editable en Lobby, conectado
a cobros/misiones y renovación B11; B12 de apuntado moderno sincronizado a Match
y verificado con funciones exactas en Studio. Prueba publicada con dos cuentas
preparada en CHECKLIST (P01..P08), todavía no ejecutada. Ambos Places en Edit y
sin publicar; contador de partidas/ranking y persistencia real continúan abiertos.

**Controles táctiles 09/10:** botones redondos DISPARAR/GANCHO/SUBIR/BAJAR,
joystick nativo en 0g y accesos de UI redondeados en Lobby y Match. Cubre parte
del punto «Móvil real» del día 7; **falta touch físico en teléfono, multitáctil
y FPS**. Detalle en CHECKLIST/DISENO; sin publicar.

- [ ] Confirmar mes/año de entrega y disponibilidad para trabajar los diez días naturales.
- [ ] Asignar responsables de código, arte/video, Dashboard y pruebas; confirmar capacidad de trabajo paralelo.
- [x] Capa global: el jugador se la lleva a su inventario de Roblox, confirmado por el usuario.
- [ ] Definir condición de reclamación, categoría/modalidad gratuita admitida, cantidad, presupuesto y propietario publicador de la capa.
- [ ] Aprobar estética, pack/pases, precios y presupuesto de compras de QA.
- [ ] Confirmar reglas de partidas/ranking y tratamiento de estadísticas históricas.
- [ ] Disponer de cuentas, móvil real, permisos de publicación y acceso al Dashboard desde el día 1.
