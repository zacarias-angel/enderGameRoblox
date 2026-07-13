# UI / Asset Spec — ZERO BREACH

Especificación del HUD y assets visuales. Toda la UI vive en
`StarterPlayer/StarterPlayerScripts` (ver `ReglasRoblox.md` §7).

---

## 1. HUD (pantalla de juego)

```
+--------------------------------------------------+
| [LED]  ZERO BREACH                    [ENERGIA]  |
|  🟢                                   ████████░░  |
|                                                  |
|                                                  |
|                       + (mira)                   |
|                                                  |
|                                                  |
|  EXTREMIDADES                                    |
|  [BrazoI][BrazoD][PiernaI][PiernaD]              |
+--------------------------------------------------+
```

### Elementos

| Elemento | Tipo | Descripción |
|----------|------|-------------|
| LED de estado | `Frame` circular | 🟢 activo / 🟡 dañado / 🔴 congelado |
| Barra de energía | `Frame` + `Frame` relleno | Energía de boost (0–100) |
| Mira | `ImageLabel`/`Frame` centro | Cruz simple |
| Panel extremidades | 4 iconos | BrazoI, BrazoD, PiernaI, PiernaD; gris=ok, azul-hielo=congelado |

---

## 2. Colores LED

| Estado | Color (RGB) | Uso |
|--------|-------------|-----|
| Activo | `85, 255, 127` (🟢) | Sin daño |
| Dañado | `255, 213, 79` (🟡) | ≥1 extremidad congelada |
| Congelado | `255, 82, 82` (🔴) | Eliminado / traje bloqueado |

Estos colores se centralizan en `Shared/Config` (`Config.LedColors`).

---

## 3. Feedback de disparo

- **Blaster**: modelo procedural (cuerpo + cañón + núcleo neón) soldado a la
  mano derecha por `WeaponSetup`, con Attachment `Muzzle` en la punta.
- **Láser**: `Part` neón cian tipo beam desde el muzzle al punto de impacto,
  con fade (~0.25 s) vía TweenService (`ShootingController`).
- **Muzzle flash**: esfera neón + `PointLight` breve en la boca del cañón.
- **Impacto**: chispa/esfera de hielo que se expande y desvanece.
- **Pose de vuelo**: astronauta procedural (`AstronautPose`) con Motor6D; no es
  UI pero es el feedback visual principal del jugador en 0g.

---

## 4. Assets a producir

| Asset | Formato | Notas |
|-------|---------|-------|
| Ícono mira | Imagen 64×64 | Cruz minimalista |
| Íconos extremidades | Imagen 48×48 ×4 | Brazo/Pierna izq/der |
| Textura pulso | Imagen/ColorSequence | Cian energético |
| Traje EVA (LED emissive) | Material/Part | SurfaceLight o Neon en el modelo |

---

## 5. Reglas de implementación

- UI separada en: **Controlador** (`HudController`), **Lógica** de datos y
  **Configuración** (colores/tamaños en `Config`). No mezclar lógica crítica
  con UI (`ReglasRoblox.md` §7).
- El HUD **solo refleja** estado recibido del servidor vía `StateChanged`.
  Nunca decide vida/congelación por su cuenta.
- La energía de boost se muestra desde el valor local, pero cualquier efecto
  de gameplay real se valida en servidor.

---

## 6. Estado MVP

Incluido en MVP: LED de estado, barra de energía, mira, panel de extremidades,
VFX básico de pulso. UI de captura de puerta y marcador de equipos → Fase 2.
