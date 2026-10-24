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
- **Cada pieza es un bot independiente:** para los demás bots, cada célula suelta (de un bot, del jugador
  o tras explotar con un virus) es un objetivo por sí misma, valorado solo por su masa y su distancia.
  Cuando un bot está dividido, cada una de sus células persigue a la presa más jugosa a su alcance
  (máximo dos por presa para no estorbarse). La lógica es idéntica contra jugadores y bots.
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
- **Bots más competitivos:** apuntan a donde estará la presa (no a donde está) y se dividen en cuanto una
  presa pequeña queda a tiro; en partidas de 200 bots esto sube su relación eliminaciones/muertes de 0,93 a 1,07.
- **Revisión de errores:** pruebas aleatorias de estrés (pausa, tema, ajustes, cambios de tamaño, muertes,
  modos), simulaciones largas con comprobación de valores raros y fugas de memoria, almacenamiento bloqueado,
  sin audio, apodos con código HTML y pantallas desde 320 px hasta 2560 px. Corregido: piezas que se
  deslizaban fuera de la arena al amontonarse contra un muro, paneles que se pisaban en móviles de 320-360 px
  y menú que se desbordaba en móviles apaisados muy pequeños.
- Accesibilidad: foco visible, roles ARIA, navegación con teclado y respeto a «reducir movimiento».
- Sonido sintetizado con WebAudio y vibración en móvil.
- Equilibrio a largo plazo: la pérdida de masa aumenta si la arena se satura o un jugador se vuelve
  descomunal, para que las partidas largas (sobre todo en Ultra) no acaben con células cubriéndolo todo.
- **Colores:** los bots tienen colores aleatorios (tono, saturación y luminosidad al azar) y estrenan
  un color nuevo cada vez que reaparecen. El jugador puede elegir la categoría **Color aleatorio** en el
  menú (volver a pulsarla cambia de color); cada partida nueva sale con un color distinto.
- **Movimiento de los bots más suave:** giran con inercia en vez de cambiar de rumbo en seco (el giro medio
  baja un 34 % y los giros bruscos se reducen a la mitad, sin perder rendimiento en combate).
- **Partida nueva:** al pulsar Jugar desde el menú todos empiezan de cero (bots incluidos). Si mueres y pulsas «Jugar de nuevo», la partida no se reinicia: los bots conservan su progreso y tú reapareces con la masa inicial.
- **Unión automática:** las piezas de una célula dividida (de jugador y de bots) se juntan solas, con suavidad, a los 30 s. En el panel de la izquierda aparece la cuenta atrás «Unión en 0:xx». Dividir, expulsar masa o explotar contra un virus reinician la cuenta atrás de todas tus piezas.
- **Teclado propio del juego (móvil y tableta):** al tocar el apodo se abre un teclado del juego en vez del del móvil, así que nada se encoge ni se queda en negro (tampoco en pantalla completa). QWERTY español con **Ñ**; mantén pulsada una vocal para los acentos (á é í ó ú ü…) o una tecla de arriba para su número; mayúscula automática al empezar cada palabra y doble toque en ⇧ para bloquearla; páginas de números y símbolos (?123, =\<) y de emojis; mantener ⌫ borra seguido; vista previa de cada tecla, vibración y sonido suaves; contador 0/15. ✓, la flecha o tocar fuera lo cierran. En PC se usa el teclado normal.
- **Comer:** una célula que puede comerte (≥25 % más masa) lo hace cuando te tapa aproximadamente la mitad
  de tu superficie, como en el Agar.io original. Antes podía taparte entre el 65 % y el 74 % sin comerte.
  Lo mismo vale para explotar al pasar sobre un virus.
- **Colisiones:** las células grandes ya no atraviesan los muros (antes podían quedar casi a medias fuera
  de la arena) y, si crecen pegadas a uno, se desplazan hacia dentro con suavidad. Las células de distinto
  dueño que no pueden comerse entre sí (tamaño parecido, o con el escudo de aparición) **chocan y se apartan
  suavemente** en vez de atravesarse como fantasmas: en partidas de 200 bots el solapamiento mediano entre
  células grandes baja del 76 % al 1 %. Al dividirse un gigante o explotar con un virus, las piezas se
  separan sin tirones (el mayor salto por fotograma baja de 153 px a 45 px), la célula comida se desliza
  hacia el borde de quien se la come y las piezas propias se empujan entre sí sin hundirse ni temblar,
  también contra un muro. Los virus y la masa expulsada rebotan con su borde.
- Rendimiento: sprites pre-renderizados, rejilla espacial y resolución adaptativa.

## Archivos

| Archivo | Contenido |
|---------|-----------|
| `index.html` | El juego completo (HTML, CSS y JS; el icono va incrustado) |
| `icons/icon.svg` | Icono vectorial |
| `icons/icon-192.png`, `icons/icon-512.png` | Iconos PNG |
| `icons/apple-touch-icon.png` | Icono de pantalla de inicio de iOS (180 px) |
