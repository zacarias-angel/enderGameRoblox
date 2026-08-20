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
- [x] Disparo con validacion en servidor.
- [x] Congelacion de extremidades y eliminacion.
- [x] Gancho como movilidad principal en batalla.
- [x] Agarre/cobertura (`GrabController`).
- [x] Lobby y batalla separados por modo de juego.
- [x] Equipos Azul/Rojo con teletransporte a la arena.
- [x] Ranking basico y economia de monedas.
- [x] Taller para mejoras/desbloqueos locales de la sesion.

### Flujo de partida actual
- [x] La entrada manual por portal fue reemplazada por cuenta regresiva global.
- [x] Todos los jugadores conectados entran al mismo tiempo.
- [x] Los jugadores se reparten en equipos en partes iguales.
- [x] La partida no arranca con menos de 2 jugadores elegibles.
- [x] Si durante la partida queda menos de 2 jugadores, termina como partida invalida.
- [x] El portal ahora es solo visual.
- [x] El HUD muestra estado de partida, contador y tiempo restante.
- [x] Existe checkbox para no entrar a la proxima batalla.

### Replicacion visual ya resuelta
- [x] Los disparos se ven para todos los jugadores.
- [x] Los ganchos se ven para todos los jugadores.

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
- [x] Batalla con gravedad cero.
- [x] MatchService con rondas automaticas.
- [x] Cuenta regresiva global antes de cada partida.
- [x] Reparto automatico de equipos al inicio.
- [x] Fin de ronda por aniquilacion o tiempo.
- [x] Reinicio al lobby.
- [x] Partida invalida si queda una sola persona.

### Fase 3 — Interaccion y movilidad extendida
- [x] Gancho funcional.
- [x] Replicacion visual del gancho.
- [x] Sistema de cobertura/agarre.
- [x] Portal solo visual.

### Fase 4 — Calidad de experiencia actual
- [x] Contador de partida visible en HUD.
- [x] Opcion de excluirse de la siguiente batalla.
- [x] Ajuste visual del checkbox debajo del contador de monedas.
- [x] Mensajes de estado arriba de pantalla, mas compactos.

---

## Proximos pasos prioritarios

### Fase 5 — Persistencia real de datos
- [ ] Crear `DataService.server`.
- [ ] Definir `DEFAULT_PROFILE` del jugador.
- [ ] Guardar monedas.
- [ ] Guardar armas desbloqueadas.
- [ ] Guardar color de laser equipado.
- [ ] Guardar mejora de estamina.
- [ ] Guardar estadisticas de combate.
- [ ] Guardar preferencia `BattleOptOut`.
- [ ] Guardado al salir del jugador.
- [ ] Guardado periodico de seguridad.
- [ ] Guardado en `BindToClose`.
- [ ] Manejo de version de datos.

### Fase 6 — Recompensa diaria
- [ ] Definir estructura `LastDailyClaimDay`.
- [ ] Definir `DailyStreak`.
- [ ] Calculo por dia UTC en servidor.
- [ ] Remote/server action para reclamar recompensa.
- [ ] UI para mostrar recompensa disponible.
- [ ] Escalera de recompensas de 7 dias.
- [ ] Reglas de reinicio o perdida de racha.

### Fase 7 — Progresion y retencion
- [ ] Hacer persistente el taller.
- [ ] Agregar misiones diarias basicas.
- [ ] Agregar recompensas por jugar / ganar / congelar.
- [ ] Agregar pantalla de resultados de ronda.
- [ ] Mostrar MVP / mejor jugador / estadisticas de la ronda.

### Fase 8 — Pulido de combate
- [ ] Revisar balance de stamina, cooldowns y recoil.
- [ ] Mejorar feedback audiovisual de impactos.
- [ ] Mejorar VFX/SFX del gancho.
- [ ] Mejorar feedback de congelacion y eliminacion.
- [ ] Revisar anti-exploit final de remotes.

### Fase 9 — Contenido y variedad
- [ ] Segundo modo de juego.
- [ ] Eventos de arena o powerups.
- [ ] Mas coberturas y layout de mapa.
- [ ] Objetivos secundarios en partida.
- [ ] Mas desbloqueos cosmeticos.

---

## Orden recomendado de implementacion

### Sprint siguiente
- [ ] 1. `DataService.server`.
- [ ] 2. Guardado de monedas, progreso y preferencias.
- [ ] 3. Recompensa diaria completa.
- [ ] 4. UI de recompensa diaria.

### Sprint despues de persistencia
- [ ] 1. Persistencia del taller.
- [ ] 2. Pantalla de resultado de ronda.
- [ ] 3. Misiones diarias simples.

### Sprint de pulido
- [ ] 1. Balancear combate.
- [ ] 2. Mejorar VFX/SFX.
- [ ] 3. Mejorar onboarding/tutorial.

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
