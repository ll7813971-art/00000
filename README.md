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
- **IA Ultra:** además de la IA normal, los bots Ultra anticipan hacia dónde se mueven los rivales
  (para huir y para apuntar), no se meten en trampas (presas protegidas por una célula mayor), se
  dividen con más precisión y no pierden tiempo persiguiendo presas que no pueden alcanzar.
  Cada mejora se midió por separado en partidas de 200 bots (100 con IA Ultra contra 100 con IA
  normal, misma habilidad, 4 minutos): la combinación elegida muere entre un 20 y un 27 % menos y su
  relación eliminaciones/muertes es ~1,2-1,3 frente a ~0,8 (el reparto de masa queda igualado). Otras ideas (disparar virus más a menudo, escanear rutas de huida,
  ampliar la visión, reaccionar más rápido, ver gigantes lejanos) empeoraban el juego y se descartaron.
- **Ataque a células divididas:** cuando un bot está dividido, cada una de sus células persigue a la
  presa más jugosa a su alcance (máximo dos por presa para no estorbarse) y valora más las piezas de
  quien está dividido. La lógica es idéntica contra jugadores y bots.
- **4 modos:** Fácil (16 bots), Normal (26), Difícil (36) y **Ultra**: mapa de 14.000 (más de 5 veces
  el área), **200 bots**, 15.000 piezas de comida, más virus y bots con una IA mejorada
  (ver «IA Ultra» más arriba). Al elegir un modo, el fondo del menú pasa a mostrar esa partida.
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
- Equilibrio a largo plazo: la pérdida de masa aumenta si la arena se satura o un jugador se vuelve
  descomunal, para que las partidas largas (sobre todo en Ultra) no acaben con células cubriéndolo todo.
- Rendimiento: sprites pre-renderizados, rejilla espacial y resolución adaptativa.

## Archivos

| Archivo | Contenido |
|---------|-----------|
| `index.html` | El juego completo (HTML, CSS y JS; el icono va incrustado) |
| `icons/icon.svg` | Icono vectorial |
| `icons/icon-192.png`, `icons/icon-512.png` | Iconos PNG |
| `icons/apple-touch-icon.png` | Icono de pantalla de inicio de iOS (180 px) |
