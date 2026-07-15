# Ruta / Checklist de Desarrollo — ZERO BREACH (PvP 0g)

Roadmap por fases. El MVP es el núcleo jugable; el resto se construye encima.
(Nota: este archivo reemplaza el placeholder "PETS_Y_PVP"; el juego no usa pets.)

---

## Fase 0 — Estructura del proyecto
- [ ] Crear jerarquía de carpetas en Studio (ver `ReglasRoblox.md` §1).
- [ ] `Workspace.Gravity = 0`.
- [ ] Arena cubo básica (paredes + spawns).
- [ ] Coberturas de prueba (cubos flotantes anclados).

## Fase 1 — MVP: Núcleo jugable
### Movimiento 0g
- [ ] `Shared/Config` con constantes de física.
- [ ] `StarterCharacterScripts/ZeroGSetup`: desactiva walk, crea VectorForce.
- [ ] `StarterPlayerScripts/MovementController`: WASD + Espacio/Ctrl + Boost.
- [ ] Inercia + clamp de velocidad + drag suave.
- [ ] Energía de boost (consumo + regeneración).

### Disparo + congelación
- [ ] `Modules/FreezeMap`: parte impactada → efecto.
- [ ] `RemoteEvents/FireWeapon` y `StateChanged`.
- [ ] `StarterPlayerScripts/ShootingController`: raycast desde cámara + VFX.
- [ ] `ServerScriptService/ShootingService`: validación + re-raycast servidor.
- [ ] `ServerScriptService/FreezeService` + `PlayerStateService`: estado por
      jugador, congelación de extremidades, eliminación.
- [ ] Reducción de empuje por piernas congeladas.
- [ ] Eliminado queda flotando (no despawnea).

### HUD
- [ ] `StarterPlayerScripts/HudController`: LED, energía, mira, extremidades.

### Cierre MVP
- [ ] Probar: volar, boost, disparar, congelar extremidad, eliminar.
- [ ] Checklist de `ReglasRoblox.md` cumplido en cada script.

## Fase 2 — Equipos y objetivo
- [ ] Sistema de equipos Azul/Rojo + spawns por equipo.
- [ ] Escudos humanos: anclaje a la espalda del torso (sin cancelar giro);
      carry completo en evaluación (ver Sesión 9 en `PROGRESO_DIARIO.md`).
- [ ] Mira ADS: mantener click derecho (FOV + mira + sensibilidad).
- [ ] Lobby con gravedad normal + modo batalla/duelo en 0g.
- [ ] Interruptor caótico del lobby: `Workspace.Gravity = 0` global
      (no afecta al modo batalla, que ya está en 0g).
- [ ] Puerta de Extracción: 4 sensores + captura 3–5 s (`CaptureService`).
- [ ] UI de progreso de captura + marcador.
- [ ] Condición de victoria 1 (aniquilación) y 2 (puerta).
- [ ] Ciclo de ronda (inicio, victoria, reinicio).

## Fase 3 — Contenido y pulido
- [ ] Coberturas variadas: tubos, anillos, paneles, contenedores, restos.
- [ ] Roles / cosméticos por estilo de juego.
- [ ] VFX/SFX de propulsores, pulsos e impactos.
- [ ] Balance de energía, empuje, tiempos de congelación.
- [ ] Anti-exploit final (auditoría regla de oro `ReglasRoblox.md` §10).

---

## Checklist de calidad por script (obligatorio)
- [ ] Tipo de script aclarado (Script/LocalScript/ModuleScript)
- [ ] Ubicación aclarada
- [ ] Contexto aclarado (Cliente/Servidor/Compartido)
- [ ] Funciones documentadas (Propósito/Precondiciones/Ubicación/Retorna)
- [ ] Validaciones en servidor
- [ ] Sin lógica sensible en cliente
- [ ] RemoteEvents validados
- [ ] Código modular, nombres consistentes, sin prints innecesarios
