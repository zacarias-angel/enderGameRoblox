# Ruta / Checklist de Desarrollo — ZERO BREACH (PvP 0g)

Documento vivo para ordenar lo que ya existe, lo que esta en curso y los
proximos pasos recomendados.

---

## Estado actual

### Base jugable ya implementada
- [x] Estructura principal del proyecto en `src/`.
- [x] Configuracion central en `ReplicatedStorage/Shared/Config`.
- [x] Movimiento 0g con `VectorForce`, drag, boost y limite de velocidad.
- [x] HUD base con energia, mira, LED e iconos de extremidades.
- [x] Barra separada para energia del gancho.
- [x] Disparo con validacion en servidor.
- [x] Congelacion de extremidades y eliminacion.
- [x] Gancho como movilidad principal en batalla.
- [x] Agarre/cobertura (`GrabController`).
- [x] Lobby y multiples batallas separados por jugador/`matchId`.
- [x] Equipos Azul/Rojo con teletransporte a la arena.
- [x] Ranking basico y economia de monedas.
- [x] Taller para mejoras/desbloqueos locales de la sesion.

### Flujo de partida actual
- [x] Migrado el flujo competitivo a Places y Reserved Servers.
- [x] El gestor global anterior esta reemplazado por partidas independientes.
- [x] Existe una cola separada por formato.
- [x] Cada partida tiene `matchId`, jugadores, equipos, arena y temporizador propios.
- [ ] Verificar con dos clientes que varias partidas del mismo formato se ejecuten simultaneamente.
- [x] `LIBRE` acepta jugadores en una instancia abierta sin temporizador.
- [x] Los jugadores competitivos permanecen en lobby hasta completar su grupo.
- [x] Cada jugador puede suscribirse a una sola cola.
- [x] Repetir el portal quita al jugador de la cola.
- [x] Usar otro portal cambia la suscripcion de formato.
- [ ] Revalidar en produccion el loop completo: perder → ganador → lobby sin estado residual.
- [ ] Los portales fisicos son persistentes en `Workspace.BattlePortals`.
- [ ] El HUD muestra estado y tiempo solo cuando corresponde a la partida del jugador.
- [x] Existe checkbox para no entrar a la proxima batalla.

### Replicacion visual ya resuelta
- [x] Los disparos se ven para todos los jugadores.
- [x] Los ganchos se ven para todos los jugadores.
- [x] La punta del gancho usa un modelo 3D reemplazable.
- [x] La cuerda del gancho usa visual configurable por cosmetico.

---

## Paso a paso de lo ya hecho

### Fase 0 — Base tecnica
- [x] Crear jerarquia de scripts cliente/servidor/compartido.
- [x] Definir constantes globales en `Config`.
- [x] Preparar servicios base: estado del jugador, congelacion, modo de juego.

### Fase 1 — MVP jugable

#### Movimiento 0g
- [x] `StarterCharacterScripts/ZeroGSetup`.
- [x] `StarterPlayerScripts/MovementController`.
- [x] Inercia, drag y clamp de velocidad.
- [x] Boost con consumo/regeneracion.

#### Disparo y combate
- [x] `Modules/FreezeMap`.
- [x] `RemoteEvents/FireWeapon` y `StateChanged`.
- [x] `StarterPlayerScripts/ShootingController`.
- [x] `ServerScriptService/ShootingService`.
- [x] `ServerScriptService/FreezeService`.
- [x] `ServerScriptService/PlayerStateService`.
- [x] Reduccion de movilidad por piernas congeladas.
- [x] Eliminado flotando en arena.

#### HUD
- [x] Mira.
- [x] Barra de energia.
- [x] LED de estado.
- [x] Panel de extremidades.

### Fase 2 — Lobby, equipos y rondas
- [x] Equipos Azul/Rojo.
- [x] Spawns por equipo.
- [x] Lobby con gravedad normal.
- [x] Batalla con gravedad cero aislada por jugador/`matchId`.
- [x] MatchService con registro de partidas independientes.
- [x] Cuenta regresiva propia por partida competitiva.
- [x] Reparto automatico de equipos por `matchId`.
- [x] Fin de ronda por aniquilacion o tiempo, aislado por `matchId`.
- [x] Reinicio al lobby aislado por partida.
- [x] Cancelacion segura de una partida incompleta.

### Fase 3 — Interaccion y movilidad extendida
- [x] Gancho funcional.
- [x] Replicacion visual del gancho.
- [x] Sistema de cobertura/agarre.
- [x] Portales persistentes con estado independiente por formato.

### Fase 4 — Calidad de experiencia actual
- [x] Contador de partida visible en HUD.
- [x] Opcion de excluirse de la siguiente batalla.
- [x] Ajuste visual del checkbox debajo del contador de monedas.
- [x] Mensajes de estado arriba de pantalla, mas compactos.

---

## Proximos pasos prioritarios

### Fase 5 — Persistencia real de datos
- [x] Crear `DataService.server`.
- [x] Definir `DEFAULT_PROFILE` del jugador.
- [x] Guardar monedas.
- [x] Guardar armas desbloqueadas.
- [x] Guardar color de laser equipado.
- [x] Guardar mejora de estamina.
- [x] Guardar estadisticas de combate.
- [x] Guardar preferencia `BattleOptOut`.
- [x] Guardado al salir del jugador.
- [x] Guardado periodico de seguridad.
- [x] Guardado en `BindToClose`.
- [ ] Manejo de version de datos.

### Fase 6 — Recompensa diaria
- [x] Definir estructura `LastDailyClaimDay`.
- [x] Definir `DailyStreak`.
- [x] Calculo por dia UTC en servidor.
- [x] Remote/server action para reclamar recompensa.
- [x] UI para mostrar recompensa disponible.
- [x] Escalera de recompensas de 7 dias.
- [ ] Reglas de reinicio o perdida de racha.

### Fase 7 — Progresion y retencion
- [x] Hacer persistente el taller.
- [x] Agregar misiones diarias basicas.
- [x] Agregar recompensas por jugar / ganar / congelar.
- [x] Agregar pantalla de resultados de ronda.
- [x] Mostrar MVP / mejor jugador / estadisticas de la ronda.
- [x] Hacer persistentes los cosmeticos de gancho equipados.
- [x] Primer logro: completar todas las misiones diarias.

### Recompensas activas de ronda
- Jugar partida: `+15` monedas.
- Ganar partida: `+30` monedas extra.
- Congelar extremidad a un rival jugador: `+2` monedas.
- Eliminar a un rival jugador: `+8` monedas.
- `Partida invalida`: no entrega recompensa de ronda.
- El dummy/NPC de prueba no entrega monedas.

### Logros activos
- `Cumpliste todas las misiones diarias`:
  - condicion: reclamar todas las misiones del dia
  - recompensa unica: `+120` monedas
  - persistente en perfil del jugador

### Fase 8 — Formatos de batalla y arenas
> Esta fase queda marcada como prototipo local. Para produccion se reemplaza
> por la Fase 12 de Places y TeleportService.
- [x] Separar configuracion de formato de partida: `LIBRE`, `1v1`, `2v2`, `3v3`, `4v4`.
- [x] Permitir elegir formato de batalla antes de entrar a la ronda.
- [x] Selector físico en el lobby mediante estaciones `LIBRE`, `1v1`, `2v2`, `3v3` y `4v4`.
- [x] Cada portal muestra jugadores y plazas de su propia cola/partida.
- [x] `LIBRE` transporta al jugador a una instancia abierta inmediatamente.
- [x] Los modos competitivos esperan en lobby hasta completar grupos independientes.
- [x] El jugador puede salir de cualquier batalla con boton, tecla `X` o portal.
- [x] Crear una arena por `matchId` dentro de `Workspace.ActiveArenas`.
- [x] Configurar `LIBRE`: entrada inmediata, sin limite de tiempo ni eliminaciones.
- [x] Configurar capacidades de `1v1`, `2v2`, `3v3` y `4v4`.
- [x] Crear multiples partidas completas cuando una cola supera una capacidad.
- [x] Enviar al lobby al jugador congelado en `LIBRE`.
- [x] Mantener al último superviviente de `LIBRE` en gravedad 0 hasta que salga.
- [x] Replicar el total persistente de eliminaciones mediante el atributo `Eliminations`.
- [x] Aplicar penalizacion de empuje por congelacion solo desde `90%` de progreso.
- [x] Separar completamente el matchmaking por cola y por `matchId`.
- [x] Replicar formato y `matchId` al HUD y a los jugadores correctos.
- [x] Mantener conteos independientes por portal, cola y partida.
- [x] Evitar duplicados de jugador en colas diferentes.
- [x] Quitar dependencia de `Workspace.Gravity` global para lobby y arenas simultaneas.

### Fase 9 — Gancho, energia y taller
- [x] Separar energia del gancho de la energia de disparo.
- [x] Agregar barra propia para energia/carga del gancho en HUD.
- [x] Hacer que usar el gancho gaste estamina.
- [x] Definir regeneracion, costo y cooldown del gancho por balance.
- [x] Agregar mejora de estamina/capacidad del gancho en el taller.
- [x] Agregar mejora de regeneracion del gancho en el taller.
- [x] Revisar balance conjunto entre disparo, boost y gancho.
- [x] Crear slot cosmetico para la punta del gancho.
- [x] Crear slot cosmetico para la cuerda del gancho.
- [x] Hacer que la punta del gancho use un modelo reemplazable.
- [x] Hacer que la cuerda del gancho use visual/material reemplazable.
- [x] Agregar cosmeticos de gancho al taller.
- [x] Permitir equipar punta y cuerda por separado.
- [x] Replicar a todos los clientes el cosmetico equipado del gancho.

### Balance actual aplicado
- Boost:
  - `BOOST_MULTIPLIER = 2.0`
  - `BOOST_DRAIN_PER_SEC = 24`
  - `REGEN_PER_SEC = 18`
- Disparo:
  - `Blaster.shotCost = 24`
  - `Rifle.shotCost = 20`
  - `Cañon.shotCost = 55`
- Gancho:
  - `USE_COST = 25`
  - `PULL_DRAIN_PER_SEC = 24`
  - `REGEN_PER_SEC = 5`
  - `MIN_TO_USE = 25`
- Comportamiento del gancho:
  - al llegar al punto ya no se corta solo
  - se mantiene mientras `Q` siga presionada

### Fase 10 — Pulido de combate
- [ ] Diseñar beneficios de `LIBRE` por permanencia y jugadores congelados.
- [ ] Revisar balance de stamina, cooldowns y recoil.
- [ ] Mejorar feedback audiovisual de impactos.
- [ ] Mejorar VFX/SFX del gancho.
- [ ] Mejorar feedback de congelacion y eliminacion.
- [ ] Revisar anti-exploit final de remotes.

### Fase 11 — Contenido y variedad
- [ ] Segundo modo de juego.
- [ ] Eventos de arena o powerups.
- [ ] Mas coberturas y layout de mapa.
- [ ] Objetivos secundarios en partida.
- [ ] Mas desbloqueos cosmeticos.

### Fase 12 — Places y servidores reservados
- [x] Crear `Lobby Place` y `Match Place` dentro de la misma Experience.
- [x] Registrar `LobbyPlaceId` y `MatchPlaceId` en configuracion compartida.
- [x] Crear `LobbyTeleportService` para colas y grupos completos.
- [x] Crear `TeleportOptions` con `ShouldReserveServer = true`.
- [x] Pasar `MatchId` y formato mediante `TeleportData`.
- [x] Crear `MatchRuntimeService` exclusivo del `Match Place`.
- [x] Llevar combate, equipos y resultados al `Match Place`.
- [x] Teletransportar jugadores de vuelta al Lobby al finalizar o ser eliminados.
- [x] Reintentar el retorno al Lobby hasta tres veces ante fallo de `TeleportAsync`.
- [x] Registrar la mision `Jugar 1 partida` al entrar a `LIBRE` o retornar de un VS.
- [ ] Validar en produccion resultado de `1v1`, retorno de ambos y avatar flotante.
- [ ] Probar varios servidores reservados desde Roblox Player publicado.

---

## Orden recomendado de implementacion

### Cierre del dia / foco acordado
- [x] Dejar como prioridad inmediata el sprint de persistencia.
- [x] Al terminar persistencia, avanzar con formatos de batalla, energia separada del gancho y cosmeticos del gancho.
- [ ] Mantener como orden acordado los siguientes dos bloques de sprint:

### Sprint siguiente
- [ ] 1. `DataService.server`.
- [ ] 2. Guardado de monedas, progreso y preferencias.
- [ ] 3. Recompensa diaria completa.
- [ ] 4. UI de recompensa diaria.

### Sprint despues de persistencia
- [ ] 1. Persistencia del taller.
- [ ] 2. Places, `TeleportService` y servidores reservados para `LIBRE`, `1v1`, `2v2`, `3v3` y `4v4`.
- [ ] 3. Energia separada del gancho + barra propia.
- [ ] 4. Cosmeticos de punta/cuerda del gancho en taller.
- [ ] 5. Pantalla de resultado de ronda.
- [ ] 6. Misiones diarias simples.

### Sprint de pulido
- [ ] 1. Balancear combate.
- [ ] 2. Balancear costo/regeneracion del gancho.
- [ ] 3. Mejorar VFX/SFX.
- [ ] 4. Mejorar onboarding/tutorial.

---

## Checklist de calidad por script
- [ ] Tipo de script aclarado.
- [ ] Ubicacion aclarada.
- [ ] Contexto aclarado.
- [ ] Funciones documentadas.
- [ ] Validaciones en servidor.
- [ ] Sin logica sensible en cliente.
- [ ] RemoteEvents validados.
- [ ] Codigo modular y consistente.
- [ ] Sin prints innecesarios para produccion.

---

## Notas operativas
- Los cambios reales del juego deben hacerse en Roblox Studio y luego reflejarse en `src/`.
- `src/` funciona como copia local para control de cambios y push al final del dia.
- Antes de cerrar cada sesion conviene dejar este checklist actualizado.
