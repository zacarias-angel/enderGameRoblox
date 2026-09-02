# Matchmaking Multi-Instancia - ZERO BREACH

> Estado: **superado para produccion**. Este documento describe la alternativa
> de arenas clonadas dentro del mismo servidor. La arquitectura oficial ahora
> usa Places y servidores reservados; ver `ARQUITECTURA_PLACES_TELEPORT.md`.
> `LIBRE` es la excepcion: permanece en la arena local del Lobby Place.

Documento tecnico para reemplazar el gestor global de partidas.

## Objetivo

Permitir que varias partidas existan al mismo tiempo dentro del mismo servidor.
Ejemplo: 20 jugadores pueden formar diez partidas `1v1` independientes sin
compartir estado, equipos, arena ni temporizador.

## Problemas que reemplaza

El gestor anterior tenia un unico:

- `formatId`
- estado de partida
- cola
- tabla de equipos
- arena activa
- temporizador

Ese diseño bloquea los portales cuando una partida ya esta activa y no permite
crear dos partidas del mismo formato en paralelo.

## Modelo de datos

El servidor debe mantener un registro de partidas, no una sola partida:

```text
matches[matchId] = {
    id,
    formatId,
    state,
    players,
    teams,
    arena,
    timer,
    createdAt
}
```

Tambien debe existir una cola por formato:

```text
waiting["1v1"] = { playerA, playerB, ... }
waiting["2v2"] = { ... }
waiting["3v3"] = { ... }
waiting["4v4"] = { ... }
```

`LIBRE` no usa cola competitiva. Usa directamente la escena normal
`Workspace.geodesica` y acepta jugadores mientras no alcance su capacidad.

Cada jugador debe tener como maximo un `matchId` activo. El servidor es la unica
autoridad para asignar, mover, finalizar o retirar jugadores.

## Flujo competitivo

1. El jugador usa el portal de un formato.
2. El servidor valida que no este en otra partida.
3. El jugador entra en `waiting[formatId]`.
4. Mientras espera permanece en el lobby.
5. Cuando la cola alcanza la capacidad exacta, se extrae un grupo completo.
6. Se crea una nueva escena clonando
   `ServerStorage.ArenaTemplates.CompetitiveArena` dentro de
   `Workspace.ActiveArenas`.
7. Se asignan equipos y se guarda el `matchId` en cada jugador.
8. Se inicia la cuenta regresiva y luego la partida.
9. Solo los jugadores de ese `matchId` reciben estado, eventos y teletransporte
   de esa partida.
10. Al terminar, se destruye solo esa arena y sus jugadores vuelven al lobby.

Si una cola tiene jugadores sobrantes, se crean tantas partidas completas como
sea posible y el resto continua esperando.

## Suscripcion a una cola

Cada jugador puede estar en una sola cola competitiva a la vez:

- Primer uso de un portal: suscribe al jugador al formato.
- Segundo uso del mismo portal: lo quita de esa cola.
- Uso de otro portal: lo quita de la cola anterior y lo suscribe al nuevo
  formato.
- El servidor rechaza cualquier duplicado aunque lleguen solicitudes repetidas.

Logs operativos esperados:

- `QUEUE_ADD`
- `QUEUE_DUPLICATE`
- `QUEUE_TOGGLE_OFF`
- `QUEUE_SWITCH`
- `QUEUE_REMOVE`

## Flujo LIBRE

1. El primer jugador crea la instancia `LIBRE` si no existe.
2. Entra inmediatamente a esa arena.
3. Los siguientes jugadores se agregan a la misma instancia abierta.
4. No hay cuenta regresiva, temporizador ni condicion de victoria global.
5. Un jugador puede salir con el boton de salida, la tecla `X` o el portal.
6. Un jugador congelado vuelve al lobby sin finalizar la instancia.
7. La instancia se destruye solo cuando queda vacia.

El portal `LIBRE` debe llamar a la entrada directa si la instancia ya esta
activa. No debe intentar cambiar un formato global antes de admitir al jugador.

## Portales

Los portales son objetos permanentes en `Workspace.BattlePortals`:

- `Portal_LIBRE`
- `Portal_1v1`
- `Portal_2v2`
- `Portal_3v3`
- `Portal_4v4`

El servidor configura sus `ProximityPrompt`, pero no crea ni destruye la
geometria de los portales durante la partida. Las escenas competitivas si se
clonan desde la plantilla, y cada clon se coloca en una zona espacial distinta.

El estado visual de cada portal debe calcularse por separado:

- `LIBRE`: abierto si aun tiene capacidad.
- Competitivo: muestra jugadores esperando y plazas disponibles.
- Nunca pintar todos los portales rojos porque otra partida esta activa.
- El color visual nunca debe desactivar por si solo el `ProximityPrompt`.

## Gravedad y fisica

`Workspace.Gravity` es global. Por eso no se puede usar para separar lobby y
varias arenas simultaneas.

Regla del nuevo sistema:

- Mantener `Workspace.Gravity` en gravedad normal del servidor.
- Aplicar compensacion de gravedad por personaje dentro de una partida.
- Quitar esa compensacion al volver al lobby.
- El movimiento 0g, la pose y las restricciones de combate deben depender del
  `matchId` del jugador, no de un modo global del servidor.

El `GameModeService` global no debe decidir si todos los jugadores estan en
batalla. Puede conservarse para compatibilidad visual, pero la autoridad real
debe ser el estado individual del jugador y su `matchId`.

## Remotes y contratos

Los remotes existentes deben transportar un identificador de partida:

- `MatchStateChanged`: incluye `matchId`, `formatId`, estado y jugadores de esa
  partida.
- `LeaveMatchRequest`: solo permite salir de la partida del jugador.
- `JoinMatchRequest`: no acepta un formato enviado como autoridad; el servidor
  obtiene el formato del portal validado.
- `SetMatchFormat`: no debe cambiar una partida activa; idealmente se elimina
  cuando la seleccion se hace solo por portal.

## Reglas de seguridad

- El cliente no puede escoger `matchId`.
- El cliente no puede mover jugadores a una arena.
- El cliente no puede iniciar, finalizar ni declarar ganador.
- Un jugador no puede estar en dos colas o partidas.
- La capacidad se valida en servidor antes de insertar en una cola.
- Al desconectarse un jugador, solo se recalcula su propia partida.
- Una partida competitiva incompleta se cancela y todos sus jugadores vuelven al
  lobby sin dejar arena ni estado residual.

## Orden de implementacion

1. Crear `MatchRegistry` como ModuleScript de servidor.
2. Migrar `MatchService` para usar `MatchRegistry`.
3. Separar colas por formato y crear `matchId` por partida.
4. Migrar teletransporte, equipos, congelamiento y resultados a `matchId`.
5. Convertir `LIBRE` en instancia abierta persistente hasta quedar vacia.
6. Actualizar portales para consultar su propia cola/instancia.
7. Quitar el temporizador y el cierre global de `LIBRE`.
8. Refactorizar gravedad y movimiento para no depender de `Workspace.Gravity` por
   modo global.
9. Probar 20 jugadores simulados: diez `1v1`, cinco `2v2`, y mezclas de formatos.

## Criterios de aceptacion

- Dos partidas `1v1` pueden estar activas simultaneamente.
- Una partida `2v2` no recibe jugadores de otra partida.
- Un jugador adicional puede entrar a `LIBRE` aunque ya este activa.
- `LIBRE` no muestra ni incrementa temporizador.
- Un portal activo no cambia el color de los demas portales.
- Lobby y arenas simultaneas conservan el comportamiento de gravedad correcto.
- Al finalizar una partida se destruye solo su arena y se limpian sus jugadores.
