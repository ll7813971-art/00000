# Agar Nova

Réplica de **Agar.io** en HTML5 (Canvas 2D), en un solo archivo `index.html` sin dependencias.
Jugable en **PC, móvil y tablet**, con tema **negro** y **blanco**.

## Cómo jugar

Abre `index.html` en cualquier navegador moderno (doble clic o sírvelo con cualquier servidor estático).

| Acción          | PC                | Móvil / Tablet                       |
|-----------------|-------------------|--------------------------------------|
| Moverse         | Ratón             | Arrastra el dedo (joystick fijo)     |
| Dividirse       | `Espacio`         | Botón **DIVIDIR**                    |
| Expulsar masa   | `W` (mantener)    | Botón **MASA** (mantener)            |
| Zoom            | Rueda del ratón   | Automático                           |
| Pausa           | `Esc` / `P`       | Botón de pausa                       |
| Cambiar tema    | `T`               | Menú / Ajustes                       |
| Silenciar       | `M`               | Ajustes                              |

## Características

- **Mecánicas de Agar.io:** comer comida y células un 25 % más pequeñas, dividirse (hasta 16 células),
  fusión tras un tiempo, expulsar masa, virus que revientan a las células grandes, alimentar virus
  (7 veces) para dispararlos, pérdida de masa en células grandes y protección de 3 s al aparecer.
- **Bots inteligentes** con personalidad y nivel de habilidad: huyen de amenazas (incluido el alcance
  de división del rival), persiguen presas anticipando su movimiento, atacan dividiéndose, se esconden
  en virus cuando son pequeños, evitan virus cuando son grandes y los más hábiles disparan virus contra
  rivales grandes. Crecen, se atacan entre ellos y reaparecen.
- **Ataque a células divididas:** cuando un bot está dividido, cada una de sus células persigue a la
  presa más jugosa a su alcance (máximo dos por presa para no estorbarse) y valora más las piezas de
  quien está dividido. La lógica es idéntica contra jugadores y bots.
- **4 modos:** Fácil (16 bots), Normal (26), Difícil (36) y **Ultra**: mapa de 14.000 (más de 5 veces
  el área), **200 bots**, 15.000 piezas de comida, más virus y bots con una IA mejorada
  (ver «IA Ultra» abajo). Al elegir un modo, el fondo del menú pasa a mostrar esa partida.
- **Reiniciar fondo:** botón del menú (o tecla `R`) que genera de nuevo la partida que se ve de fondo,
  con el modo seleccionado.
- **Temas negro y blanco** (también en el lienzo: arena, cuadrícula, comida y minimapa), que se recuerdan.
- **Interfaz:** pantalla de carga, menú con vista previa de la skin, estadísticas acumuladas
  (récord, partidas, eliminados), hoja de **Ajustes** (tema, sonido y volumen, vibración, masa,
  cuadrícula, FPS y calidad gráfica), clasificación con barras, minimapa, avisos de eliminaciones y de
  llegar al puesto 1, pausa con estadísticas y pantalla de muerte con resumen.
- **Icono** propio (`icons/`): favicon, icono de pantalla de inicio para iOS/Android y marca dentro del juego.
- Accesibilidad: foco visible, roles ARIA, navegación con teclado y respeto a «reducir movimiento».
- Sonido sintetizado con WebAudio y vibración en móvil.
- Rendimiento: sprites pre-renderizados, rejilla espacial y resolución adaptativa.

## Archivos

| Archivo | Contenido |
|---------|-----------|
| `index.html` | El juego completo (HTML, CSS y JS; el icono va incrustado) |
| `icons/icon.svg` | Icono vectorial |
| `icons/icon-192.png`, `icons/icon-512.png` | Iconos PNG |
| `icons/apple-touch-icon.png` | Icono de pantalla de inicio de iOS (180 px) |
