# Diseno del sistema de disparo y congelamiento

## Reglas principales

- El rayo es continuo mientras el jugador mantiene presionado el disparo.
- Cada tick del rayo aplica el valor `freezePercentPerTick` del arma.
- El progreso se acumula en un unico valor por enemigo, de `0%` a `100%`.
- Todas las partes del cuerpo suman progreso: torso, brazos, piernas y accesorios que resuelvan a torso.
- La cabeza no elimina instantaneamente. Aplica el dano base multiplicado por `3`.
- Con la configuracion actual, un impacto de cabeza aplica el daño base del
  arma multiplicado por `3`.
- El enemigo solo queda completamente congelado al alcanzar `100%`.
- Al llegar a `100%` se detiene su movimiento, se aplica el estado de congelado y se actualiza la eliminacion del jugador.
- Si el rayo deja de impactar, el progreso no se reinicia.

## Configuracion actual

Los valores viven en `ReplicatedStorage.Shared.Config`:

- `Config.WeaponSystem.MODE = "beam"`
- `Config.WeaponSystem.BEAM_TICK_RATE = 0.1`
- `Config.WeaponSystem.BEAM_STAMINA_DRAIN_PER_SEC = 67.5`
- `Config.WeaponSystem.BEAM_WAVE_AMPLITUDE = 3.0`
- `Config.WeaponSystem.BEAM_HEAD_MULTIPLIER = 3`
- `Config.FreezeProgress.MAX = 100`

El balance actual por tick es Blaster `4.5%`, Rifle `3.6%` y Cañón `9%`. La
cabeza aplica tres veces el valor base.

## Danos y futuras armas

Cada arma ajusta su congelamiento mediante `freezePercentPerTick` sin cambiar la regla global. El multiplicador de cabeza debe seguir siendo global o configurable por arma, pero nunca debe convertir la cabeza en una eliminacion instantanea.

Ejemplos de balance:

- Blaster: `4.5%` por tick.
- Rifle: `3.6%` por tick.
- Cañón: `9%` por tick.

## VFX

- El cliente mantiene el Beam local para el tirador.
- `RemoteVfx.client` dibuja el Beam remoto para los demas jugadores.
- El impacto usa luz y particulas en el punto final del rayo.
- La ondulacion del rayo usa una amplitud compartida de `3.0`, ligeramente mayor para reforzar el efecto visual.
- El color y ancho siguen dependiendo del arma/equipamiento.
- El porcentaje se muestra en el Billboard del objetivo y se actualiza en cada impacto valido.

## Correccion aplicada

`ShootingController.client` inicializa `beamBlockedUntil = 0`. Cuando la stamina llega a cero, el servidor envia el evento de sobrecalentamiento y el cliente ya puede ejecutar `math.max` sin recibir `nil`.

`FreezeService.server` ya no congela brazos o piernas de forma binaria. Todos los impactos pasan por `addFreezeProgress`; por eso un rayo que sigue apuntando a un brazo continua acumulando dano y no se queda sin efecto por un estado de extremidad.

## Pruebas manuales

1. Iniciar una partida con dos jugadores.
2. Mantener el rayo sobre un brazo y comprobar que el porcentaje sube continuamente.
3. Mover el rayo a torso, pierna y cabeza y comprobar que todos suman al mismo porcentaje.
4. Confirmar que la cabeza sube tres veces mas rapido que una parte normal.
5. Mantener el rayo hasta `100%` y confirmar que el enemigo queda congelado.
6. Vaciar la stamina mientras el rayo esta activo y confirmar que no aparece el error `invalid argument #1 to 'max'`.
7. Soltar y volver a mantener el disparo para verificar que el Beam y sus VFX se limpian y vuelven a crearse correctamente.
