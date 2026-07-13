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
- (MVP inicial: todos-contra-todos. Equipos se activan en Fase 2.)

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

---

## 4. Movimiento

Cada jugador tiene **propulsores** y se mueve en seis direcciones:

- Adelante / Atrás
- Izquierda / Derecha
- Arriba / Abajo

Además existe un **Boost** que consume energía.

### Feel físico (clave)
- Movimiento basado en **empuje con inercia** (VectorForce), no velocidad fija.
- Al soltar los controles el jugador **sigue derivando**.
- Clamp de velocidad máxima + drag suave para mantener control.

### Controles (MVP, teclado)
| Acción | Tecla |
|--------|-------|
| Adelante / Atrás / Izq / Der | W A S D |
| Subir | Espacio |
| Bajar | Ctrl |
| Boost | Shift |
| Disparar | Click izquierdo |

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
| Pecho | Eliminación inmediata |
| Cabeza | Eliminación inmediata |

### Congelación parcial
- **Brazo congelado** → no puede sostener armas pesadas.
- **Pierna congelada** → reduce la potencia del impulso.
- **Dos piernas congeladas** → solo se desplaza lentamente con propulsores.

### Jugador congelado (eliminación)
Al recibir impacto letal (pecho/cabeza):
1. Traje bloqueado.
2. No puede moverse.
3. Queda flotando en la arena (**no desaparece**).

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

Fuera del MVP (ver roadmap): equipos, Puerta de Extracción, escudos humanos,
roles, coberturas, condiciones de victoria completas.
