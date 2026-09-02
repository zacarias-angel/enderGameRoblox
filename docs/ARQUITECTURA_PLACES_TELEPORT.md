# Arquitectura Multi-Place - ZERO BREACH

## Decision

Las partidas no se aislaran clonando arenas dentro del mismo `Workspace`.
La Experience tendra Places separados y Roblox creara un servidor reservado
para cada match.

```text
Experience
├── Lobby Place
├── Match Place
└── Training Place (futuro)
```

El jugador vera la pantalla de carga de Roblox al pasar del Lobby al Match
Place, pero seguira dentro de la misma Experience.

## Flujo

```text
Lobby Place
  -> cola por formato
  -> grupo completo
  -> TeleportAsync a servidor reservado
  -> Match Place
  -> partida aislada
  -> resultado y guardado
  -> TeleportAsync al Lobby Place
```

## Places requeridos

| Place | Uso | PlaceId |
|---|---|---|
| Lobby | portales, matchmaking, tienda e inventario | `125075465377023` |
| Match | combate, equipos, arena y resultados | `108298899371591` |
| Training | tutorial y practica | futuro |

No se debe migrar el teleport hasta probar que ambos `PlaceId` pertenecen a la
misma Experience.

## Lobby Place

Responsabilidades:

- Mantener las colas por formato.
- Validar que el jugador no este en otra cola.
- Formar grupos completos.
- Crear un `TeleportOptions` con `ShouldReserveServer = true`.
- Enviar todos los jugadores del grupo al mismo servidor reservado.
- Pasar datos no sensibles del match mediante `SetTeleportData`.
- Manejar fallos de teleport y devolver el grupo a la cola o al lobby.

El Lobby no ejecuta combate ni crea arenas de batalla.

## Match Place

Responsabilidades:

- Leer los datos recibidos con `Player:GetJoinData().TeleportData`.
- Validar el formato y el grupo en servidor.
- Crear equipos y cargar la arena local del Place.
- Ejecutar congelamiento, combate, resultado y recompensas.
- Impedir que jugadores no autorizados se mezclen en la partida.
- Teletransportar al Lobby al terminar o cancelar la partida.

El Match Place no depende de `Workspace.Gravity` compartido con el Lobby: todo
el servidor de combate puede usar 0g de forma segura.

## Datos de teleport

Ejemplo de contrato:

```lua
{
    Schema = 1,
    MatchId = "1v1_0001",
    GameMode = "1v1",
    Map = "Default",
    RoundTime = 300,
    LobbyPlaceId = 0
}
```

`MatchId` lo genera el servidor. El cliente no puede escogerlo ni modificarlo.
Los datos de progreso, monedas y resultados se validan y guardan en servidor.

## Reserved Server

Cada grupo completo usa su propio servidor reservado:

```lua
local TeleportService = game:GetService("TeleportService")
local options = Instance.new("TeleportOptions")
options.ShouldReserveServer = true
options:SetTeleportData(matchData)
TeleportService:TeleportAsync(MATCH_PLACE_ID, players, options)
```

No se crea un Reserved Server para cada jugador; se crea uno por grupo completo.

## Formatos

- `LIBRE`: se juega localmente en la arena del Lobby; no usa `TeleportAsync`.
- `1v1`: 2 jugadores por servidor reservado.
- `2v2`: 4 jugadores por servidor reservado.
- `3v3`: 6 jugadores por servidor reservado.
- `4v4`: 8 jugadores por servidor reservado.

Los formatos competitivos usan el Match Place. `LIBRE` conserva la arena
normal del Lobby y su propio flujo de eliminacion.

## Resultado y eliminaciones

- En `LIBRE`, el eliminado vuelve de inmediato al spawn del Lobby y el atacante
  recibe una eliminacion en sus estadisticas.
- En `1v1`, la eliminacion del unico rival declara ganador al equipo opuesto.
  Solo el equipo ganador recibe el estado `ENDING` y ve la pantalla de victoria.
  Tras tres segundos, los ganadores regresan al Lobby.
- En `2v2`, `3v3` y `4v4`, cada eliminado vuelve inmediatamente al Lobby y deja
  una copia congelada, flotante, colisionable y agarrable de su avatar en la
  arena. La victoria se anuncia solo al equipo que conserva supervivientes
  cuando el equipo rival queda vacio.

## Seguridad y fallos

- `TeleportAsync` se ejecuta solo en servidor.
- El grupo se marca como `Teleporting` para evitar doble envio.
- Si falla el teleport, se limpia la marca y los jugadores vuelven a la cola.
- El Match Place rechaza jugadores sin `TeleportData` valido.
- El Match Place valida que `GameMode` y cantidad de jugadores coincidan.
- Al cerrar un servidor reservado sin resultado, los jugadores regresan al
  Lobby.
- El retorno incluye `MatchId`; al llegar al Lobby, ese identificador permite
  registrar el progreso de la mision diaria `Jugar 1 partida` sin depender de
  servicios de misiones dentro del Match Place.
- El sistema no debe confiar en atributos enviados por el cliente.

## Pruebas obligatorias

TeleportService no se valida con Play Solo normal de Studio. Se debe publicar y
probar desde Roblox Player:

1. Dos jugadores forman un `1v1` y llegan al mismo servidor Match.
2. Otros dos jugadores forman otro `1v1` y no se ven entre si.
3. Un jugador en `LIBRE` no aparece en el servidor del `1v1`.
4. En un `1v1`, el ganador ve el resultado y ambos jugadores regresan al Lobby.
5. En equipos, el eliminado vuelve al Lobby y su copia queda en la arena.
6. Un fallo de teleport no deja jugadores bloqueados en estado `Teleporting`.
7. El regreso desde un Match Place avanza una vez la mision `Jugar 1 partida`.

## Migracion

1. Crear el Match Place dentro de la misma Experience.
2. Registrar ambos `PlaceId`.
3. Crear `PlaceConfig` compartido.
4. Crear `LobbyMatchmakingService` solo para colas y teleport.
5. Crear `MatchRuntimeService` solo en el Match Place.
6. Migrar combate y resultados al Match Place.
7. Retirar el `MatchRegistry` de arenas dentro de Workspace.
8. Retirar `ActiveArenas`, offsets y compensacion de gravedad por jugador.
9. Eliminar la dependencia del portal para cambiar estados globales.
