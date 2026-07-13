# Sistema de Captura — Puerta de Extracción

Documento de diseño de la condición de victoria por objetivo de ZERO BREACH.
(No hay economía de moneda en el MVP; este documento cubre la captura.)

---

## 1. Concepto

Cada base de equipo posee una **Puerta de Extracción**. Es la forma "táctica"
de ganar sin tener que aniquilar al rival: obliga a coordinar un asalto de
varios jugadores.

```
      A -------- B
      |          |
      |  PORTAL  |
      |          |
      D -------- C
```

---

## 2. Sensores

- La puerta tiene **4 sensores**: A, B, C, D (esquinas).
- Un sensor está **ocupado** cuando un jugador **vivo del equipo atacante**
  permanece dentro de su zona de detección.
- Cada sensor detecta ocupación de forma independiente (una `Part` con
  `Touched` / consulta de región en servidor).

---

## 3. Regla de activación

La puerta se activa (**captura**) cuando:

1. Los **4 sensores** están ocupados **al mismo tiempo**.
2. Por jugadores **vivos** (no congelados).
3. Del **mismo equipo**.
4. De forma **continua** durante `CAPTURE_TIME` (3–5 s, configurable).

Si en cualquier momento un sensor queda libre, el temporizador se **reinicia**.

```
4 sensores ocupados  ->  inicia contador
   |
   v
se mantiene 3-5 s     ->  PUERTA ACTIVADA  ->  Victoria
   |
   x un sensor libre  ->  reset a 0
```

---

## 4. Por qué esta regla

- Impide que **un solo jugador** gane la partida por sorpresa.
- Obliga a **coordinación** y a exponer a varios atacantes.
- Genera situaciones defensivas: el rival debe congelar aunque sea a **uno**
  de los 4 para romper la captura.

---

## 5. Autoridad y seguridad

- Toda la lógica de ocupación, temporizador y validación de equipo/vida ocurre
  en **servidor** (`ServerScriptService/CaptureService`).
- El cliente solo recibe **feedback visual** (progreso de captura, sensores
  iluminados) vía `RemoteEvent` `CaptureProgress`.
- Nunca confiar en el cliente para declarar la captura.

---

## 6. Parámetros configurables (Shared/Config)

| Constante | Valor sugerido | Descripción |
|-----------|----------------|-------------|
| `CAPTURE_TIME` | 4.0 s | Tiempo continuo para capturar |
| `SENSOR_RADIUS` | 6 studs | Radio de detección de cada sensor |
| `SENSOR_COUNT` | 4 | Sensores requeridos |

---

## 7. Estado: Fase 2

La Puerta de Extracción **no** forma parte del MVP. Depende de:
- Sistema de equipos (Azul/Rojo).
- Estado de vida por jugador (ya provisto por `PlayerStateService` del MVP).

Se implementa tras validar el núcleo de movimiento + disparo + congelación.
