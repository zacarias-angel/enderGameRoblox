# ZERO BREACH

> "La gravedad desapareció. La estrategia no."

Shooter competitivo en gravedad cero para Roblox, inspirado en la Battle Room
de *Ender's Game* pero con reglamento e identidad propios.

---

## 1. Historia

Dos escuadras entrenan dentro de una estación orbital. No existe gravedad,
solo impulsos. El combate termina cuando un equipo atraviesa la **Puerta de
Extracción** enemiga o neutraliza por completo al rival.

---

## 2. Equipos

- **Azul**
- **Rojo**
- El jugador elige un portal fisico: `LIBRE`, `1v1`, `2v2`, `3v3` o `4v4`.

Cada jugador posee un **traje EVA inteligente** que indica su estado mediante
luces LED:

| LED | Estado |
|-----|--------|
| 🟢 Verde | Activo |
| 🟡 Ámbar | Extremidad dañada |
| 🔴 Rojo | Congelado (neutralizado) |

---

## 3. Arena

Un gran **cubo espacial**. No existe piso. Todo puede recorrerse en cualquier
dirección.

```
 ___________________________________________
 Spawn Azul
        □ □ □
   ■      □        ■
         □
■                □
      □
                ■
          □
     ■
                    Spawn Rojo
_____________________________________________
```

- `□` obstáculos / coberturas flotantes
- `■` estructuras grandes
- Gravedad del mundo = 0

### Coberturas
Estructuras metálicas flotantes: **cubos, tubos, anillos, paneles,
contenedores, restos de naves**.

Sirven para: cubrir disparos · impulsarse · esconderse · cambiar dirección.

### Formatos de batalla

- `LIBRE`: entrada inmediata, sin límite de tiempo ni de eliminaciones.
- `1v1`: 2 jugadores, dos equipos de 1.
- `2v2`: 4 jugadores, dos equipos de 2.
- `3v3`: 6 jugadores, dos equipos de 3.
- `4v4`: 8 jugadores, dos equipos de 4.
- Los modos competitivos solo comienzan cuando todos sus lugares están ocupados.
- Las estaciones competitivas validan su capacidad antes de admitir: si el
  formato esta completo, la entrada se rechaza sin mover al jugador al stand.
- La selección se realiza en estaciones físicas del lobby; cada estación muestra
  jugadores dentro, fuera y plazas restantes.
- Cada formato competitivo usa un servidor reservado del `Match Place`; las
  partidas no se mezclan entre si.
- En `LIBRE`, un jugador congelado vuelve directamente al lobby y la ronda
  continúa para los demás.
- El último superviviente de `LIBRE` conserva gravedad 0 y puede seguir jugando
  o salir cuando quiera.
- No se mezclan jugadores de formatos distintos dentro de una partida.
- El Match Place admite exclusivamente los `UserId` incluidos por el Lobby en
  `PlayerUserIds` y comprueba que la cantidad sea exacta para el formato.
- Cada jugador pertenece como maximo a una partida mediante un `matchId`.
- El matchmaking multi-instancia esta definido en
  `MATCHMAKING_MULTI_INSTANCIA.md`.
- Para produccion, cada grupo viajara desde el `Lobby Place` a un servidor
  reservado del `Match Place` mediante `TeleportService`. El flujo oficial esta
   definido en `ARQUITECTURA_PLACES_TELEPORT.md`.
- Al eliminar a un jugador en `LIBRE`, vuelve al Lobby y el atacante recibe la
  eliminacion. En VS, queda una copia congelada, flotante, colisionable y
  agarrable durante la ronda; el jugador permanece en el Match Place para la
  ronda siguiente.
- Todos los VS se juegan al mejor de tres. Antes de cada ronda hay una cuenta
  regresiva de cinco segundos con movimiento y disparo bloqueados.
- Al finalizar el match, todos los participantes regresan juntos a un servidor
  reservado del Lobby mediante una sola llamada grupal de teleport.
- Cada jugador conserva el total persistente en el atributo `Eliminations`.

### Power-ups de arena

Los tres power-ups estan disponibles en `LIBRE` y en `1v1` a `4v4`:

| Color | Efecto |
|---|---|
| Amarillo | Impulso rapido en la direccion de movimiento |
| Azul | Escudo visible e inmunidad a congelacion durante 5 segundos |
| Rojo | Congelacion total al atravesarlo |

Se generan en uno de los 15 Parts de `Workspace.puntosderefe`, nunca comparten
el mismo punto y cada tipo evita sus dos ubicaciones anteriores. Tras recogerse
reaparecen en 6 segundos.

---

## 4. Movimiento

Cada jugador tiene **propulsores** y se mueve en seis direcciones:

- Adelante / Atrás
- Izquierda / Derecha
- Arriba / Abajo

Además existe un **Boost** que consume energía.

El power-up amarillo es independiente del Boost de teclado: aplica un impulso
instantaneo de velocidad `180` validado por servidor y replicado al cliente que
posee la fisica del personaje.

### Feel físico (clave)
- Movimiento basado en **empuje con inercia** (VectorForce), no velocidad fija.
- Al soltar los controles el jugador **sigue derivando**.
- Clamp de velocidad máxima + drag suave para mantener control.
- **En modo batalla el WASD está reducido al 4%**. El movimiento real se logra
  con el gancho (Q), el retroceso del disparo y el agarre/impulso (E).

### Controles (MVP, teclado)
| Acción | Tecla |
|--------|-------|
| Deriva mínima | W A S D (4% en batalla) |
| Subir / Bajar (deriva) | Espacio / Ctrl |
| Boost | Shift |
| **Gancho** (agarrarse a superficies) | **Q** (mantener) |
| **Agarre / Impulso** (coberturas) | **E** (mantener, soltar impulsa) |
| Disparar | Click izquierdo |
| Portal (unirse a partida) | F |

---

## 5. Sistema de disparo

Las armas no hacen daño tradicional: disparan **pulsos de energía**. Cada parte
del cuerpo impactada tiene un comportamiento distinto.

| Zona | Resultado |
|------|-----------|
| Brazo izquierdo | Congela el brazo |
| Brazo derecho | Congela el brazo |
| Pierna izquierda | Congela la pierna |
| Pierna derecha | Congela la pierna |
| Pecho | Suma progreso de congelamiento |
| Cabeza | Suma progreso con multiplicador `x3` |

### Congelación parcial
- **Brazo congelado** → no puede sostener armas pesadas.
- **Pierna congelada** → reduce la potencia del impulso.
- **Dos piernas congeladas** → solo se desplaza lentamente con propulsores.

### Jugador congelado (eliminación)
Al recibir congelamiento total:
1. En `LIBRE`, el jugador eliminado vuelve al Lobby.
2. En VS, el jugador queda fuera por el resto de la ronda y permanece en el
   servidor para participar en la siguiente.
3. En VS queda una copia congelada de su avatar flotando en la arena. Es una
   cobertura física que se puede empujar y agarrar con `E`.
4. La ronda suma una victoria al equipo superviviente. El match termina cuando
   un equipo gana dos rondas.
5. El atacante ve `CONGELASTE A` y la victima ve `TE CONGELO`, ambos con el
   avatar del otro jugador.

### Beam continuo
- El modo activo usa un rayo continuo mientras se mantiene el click.
- El servidor valida el raycast, atraviesa vidrio decorativo transparente y aplica
  congelamiento inmediatamente a la zona impactada.
- La barra/porcentaje de congelamiento se actualiza después de impactos de torso,
  brazos, piernas y cabeza.
- El rayo consume estamina continuamente. Al llegar a cero se corta y entra en
  enfriamiento durante `0.5 s` antes de permitir otro disparo.
- Balance actual del beam: Blaster `4.5%`, Rifle `3.6%` y Cañón `9%` de
  congelamiento por tick; drenaje de estamina `67.5/s`.
- El VFX local y remoto usa doble haz, brillo, partículas de impacto y ondulación.

---

## 6. Escudos humanos

Un compañero vivo puede **empujar** a un jugador congelado. El cuerpo flotante
se mueve lentamente y puede usarse como **cobertura móvil**. Mecánica táctica
emergente, sin elementos artificiales.

---

## 7. Condiciones de victoria

**Victoria 1 — Aniquilación:** congelar a todo el equipo rival.

**Victoria 2 — Puerta de Extracción:** cada base tiene una puerta con 4
sensores (A, B, C, D). Se activa cuando los 4 sensores están ocupados a la vez
por jugadores **vivos del mismo equipo** durante 3–5 s.

```
      A -------- B
      |          |
      |  PORTAL  |
      |          |
      D -------- C
```

Detalle en `sistema_captura_y_economia.md`.

---

## 8. Estrategias emergentes

- **Formación "Escudo"**: empujar a un congelado y disparar detrás de él.
- **Ataque vertical**: atacar desde arriba o abajo del enemigo.
- **Emboscada**: esconderse tras un contenedor grande.
- **Cadena de impulso**: un jugador impulsa a un compañero para cruzar rápido
  o alcanzar una posición elevada.

---

## 9. Roles (por estilo de juego, mismas armas)

- **Asalto** — entra primero y presiona.
- **Defensor** — protege la puerta y mantiene posiciones.
- **Francotirador** — controla líneas largas de visión.
- **Movilidad** — domina propulsores para flanquear y capturar.

---

## 10. Qué lo hace especial

No es solo un shooter en gravedad cero. La combinación de **inercia**,
**congelación localizada**, **compañeros convertidos en cobertura** y una
**condición de victoria que exige coordinación** hace cada partida un juego de
habilidad *y* estrategia.

---

## 11. Alcance del MVP

Núcleo jugable:
- Movimiento 0g en 6 direcciones + Boost con energía.
- Disparo de pulsos por raycast.
- Congelación por zona (extremidades) y eliminación (pecho/cabeza).
- HUD con LED de estado + barra de energía + mira.

Fuera del MVP (ver roadmap): Puerta de Extracción, roles, condiciones de
victoria completas.
