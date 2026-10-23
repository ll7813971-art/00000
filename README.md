# Agar Nova

Réplica de **Agar.io** en HTML5 (Canvas 2D), en un solo archivo `index.html` sin dependencias.
Jugable en **PC, móvil y tablet**.

## Cómo jugar

Abre `index.html` en cualquier navegador moderno (doble clic o sírvelo con cualquier servidor estático).

| Acción          | PC                | Móvil / Tablet                       |
|-----------------|-------------------|--------------------------------------|
| Moverse         | Ratón             | Arrastra el dedo (joystick flotante) |
| Dividirse       | `Espacio`         | Botón **DIVIDIR**                    |
| Expulsar masa   | `W` (mantener)    | Botón **MASA** (mantener)            |
| Zoom            | Rueda del ratón   | Automático                           |
| Pausa           | `Esc` / `P`       | Botón de pausa                       |
| Silenciar       | `M`               | Menú / pausa                         |

## Características

- Mecánicas de Agar.io: comer comida y células un 25 % más pequeñas, dividirse (hasta 16 células),
  fusión tras un tiempo, expulsar masa, virus que revientan a las células grandes, alimentar virus
  (7 veces) para dispararlos, decaimiento de masa.
- **Bots inteligentes** con personalidad y nivel de habilidad: huyen de amenazas (incluido el
  alcance de división del rival), persiguen presas con predicción de movimiento, atacan
  dividiéndose, se esconden en virus cuando son pequeños, evitan virus cuando son grandes y los
  más hábiles disparan virus contra rivales grandes. Crecen, se atacan entre ellos y reaparecen.
- 3 dificultades (16 / 26 / 36 bots).
- UI con degradados y efecto cristal: menú animado con el mundo en vivo de fondo, clasificación,
  minimapa, feed de eliminaciones, estadísticas al morir, récord guardado.
- Animaciones: células con efecto gelatina, absorción animada, partículas, textos flotantes.
- Sonido sintetizado con WebAudio y vibración en móvil.
- Protección de 3 s al aparecer (se pierde al dividirse o expulsar).
- Rendimiento: sprites pre-renderizados, rejilla espacial y resolución adaptativa.
