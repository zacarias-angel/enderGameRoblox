# ZERO BREACH — Plan de entrega de 10 días

Creado: 2026-10-08. Fecha de entrega asumida: **20 de octubre de 2026**.
Sprint: **11–20 de octubre**, diez días naturales, incluida la entrega.
Base: [CHECKLIST](CHECKLIST.md), [BUGS](BUGS.md) y [SUGERENCIAS](SUGERENCIAS.md).
Este documento planifica trabajo; no certifica correcciones ni implementaciones.

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
| 7 | 17/10 | Montar pantalla de video y verificar permisos/reproducción. Corregir espera de ZB_Intro, revisar manual, tienda, actividades y touch. Cerrar regresiones de apuntado, cámara, respawn y salida. | Video probado en Player si ya está aprobado; interfaz y controles utilizables en escritorio y móvil; pendientes externos visibles. |
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
