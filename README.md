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
- **Colores sin repetir:** cada bot (y el jugador con **Color aleatorio**) recibe un color al azar, pero de
  64 colores candidatos se queda con el más distinto de todos los que ya hay en la arena, y estrena otro
  al reaparecer. Ningún bot lleva un color parecido al del jugador. Antes, con colores puramente al azar,
  en Ultra había ~220 parejas casi idénticas; ahora ninguna (también en partidas normales).
- **Poderes:** el mapa tiene huecos de poder (8 en los mapas normales, 44 en Ultra). Cada hueco libre tira
  cada 4 s: **30 % rayo**, **19 % bomba**, **11 % ácido**, **4 % hielo** y, si no, se queda vacío hasta la
  siguiente tirada. Salen en el minimapa (rayos en amarillo, bombas en rojo, ácido en verde, hielo en azul).
  - **Rayo ⚡:** el jugador o el bot que lo toque va **1,5 veces más rápido durante 15 s**. Deja una estela de
    imágenes residuales de la célula, una **cola de cometa** que se estrecha suave hasta la punta con un degradado
    de brillante a transparente (más larga en células grandes), **destellos en forma de estrella** que titilan a lo
    largo de ella y chispas que saltan por detrás, y lo envuelve un aura con halo de luz, dos anillos que
    giran en sentidos opuestos, pequeños rayos que chispean y chispas en órbita (dorada en el tema blanco). En los
    **últimos 3 s** se vuelve naranja y parpadea cada vez más deprisa (también la fila «⚡ Rayo» del panel) y
    al terminar se apaga con un chisporroteo. Optimizado: la cola se pinta con 2 rellenos por célula, sin mezcla de luz, y
    con muchas piezas solo llevan estela y aura completa las 4 mayores (con todos los jugadores con el rayo, de
    37 a ~50 FPS en un móvil simulado), un anillo y chispas al cogerlo y, para el jugador,
    sonido, vibración y la cuenta atrás «⚡ Rayo 0:15». Coger otro mientras dura reinicia los 15 s.
  - **Bomba 💣:** al tocarla aparece en el centro de tu célula (con la mecha encendida; tu nombre sube por
    encima de ella y la masa baja por debajo para no taparla) y sale el botón
    **LANZAR** (en PC también la tecla **E**). Se lanza hacia donde miras (el ratón o el joystick). Si toca
    una célula de otro jugador, esa célula recibe un **aura roja y una cuenta atrás de 3 s** encima y, al
    llegar a cero, una explosión (bola de fuego, onda, temblor de pantalla y sonido) la **revienta en mini
    células** (si ya tiene 16 piezas, suelta masa en bolitas). Solo tiene un uso: si no da a nadie, se
    apaga. Solo se lleva una a la vez. Los bots también las cogen y las lanzan a los rivales grandes.
  - **Ácido 🧪:** funciona como la bomba (se lleva en el centro de tu célula, botón **LANZAR** verde o tecla
    **E**, un solo uso y solo una cosa para lanzar a la vez), pero la célula alcanzada **se pone verde**, burbujea,
    gotea, lleva una calavera ☠ encima y **pierde el 8 % de su masa cada segundo durante 5 s** (se ve «-N» en
    verde). Si te envenenan, el panel avisa «☠ ¡Envenenado! N s». Los bots también lo usan. Suena al cogerlo,
    al lanzarlo, al dar (salpicadura con chisporroteo) y con cada mordisco del ácido («fsss» con burbujas). El
    matraz es de una sola pieza (cuello y cuerpo redondo), con líquido verde neón brillante, burbujas, una
    calavera pequeña y tapón de corcho.
  - **Hielo ❄:** igual que la bomba (botón **LANZAR** azul o **E**, un solo uso), pero la célula alcanzada
    queda **congelada 3 s**: se cubre de hielo azul con grietas y cristales, lleva un copo ❄ encima y **no se
    mueve nada**. Al romperse el hielo (crujido y esquirlas) **sigue azul y va muy lenta (30 %) otros 2 s**, con
    una tortuga 🐢 encima. Si te congelan, el panel avisa «❄ ¡Congelado!» y luego «🐢 Helado, vas lento».
- **Lanzamientos:** lo que lanzas (bomba, ácido, hielo) rebota en los muros y, si en **7 s** no da a nadie, se
  desvanece poco a poco. Después de rebotar todavía puede dar a alguien.
- **Flecha de puntería:** tu célula mayor lleva una flecha que apunta hacia donde miras (el ratón o el
  joystick); su color cambia según lo que lleves para lanzar. Gira con suavidad, se queda quieta si el ratón
  está encima de la célula y no salta entre piezas parecidas (así no parpadea).
- **Menos lag:** los bots lejos de la pantalla piensan con menos frecuencia, los poderes buscan células en la
  rejilla en vez de recorrerlas todas, los números se formatean sin `toLocaleString` y, si el dispositivo va
  lento, la simulación pasa a pasos de 1/30 s y no acumula más de 4 pasos por fotograma (luego baja la
  resolución). En un móvil simulado 4 veces más lento, Ultra pasa de ~20 a ~43 FPS.
- **Lanzar con la flecha:** lo que lanzas sale siempre exactamente hacia donde apunta la flecha (también
  moviéndote o con el rayo), desde la pieza de la que sale la flecha y sin sumarle la velocidad de la célula.
- **Bots divididos como un solo jugador:** las piezas de un bot dividido van todas juntas hacia el mismo
  objetivo, como las tuyas; ya no persigue cada pieza a su propia presa.
- **Bots siempre en movimiento:** si su objetivo queda encima de ellos o al otro lado del muro, siguen su rumbo
  (dándose la vuelta contra el muro) en vez de pararse; al disparar a un virus avanzan despacio hacia él.
- **Modo espectador** (botón en el menú): mira la partida sin jugar. Sigue al líder (👑) o a quien elijas con
  ◀ ▶ (o ← →), tocando su fila en la clasificación o tocando su célula; si el que miras muere, pasas al
  nuevo líder (con 👑) o a quien se lo comió. La cámara siempre enseña entero al que miras y el minimapa
  marca a quién miras y la zona visible. T y M (tema y sonido) también funcionan.
  Rueda para acercar/alejar, ▶ para jugar, ✕ o Esc para volver. Optimizado: la cámara no se aleja más de
  ~3.600 px, menos partículas, sin viñeta y la clasificación, la barra y el minimapa se refrescan menos.
- **Más optimización:** la masa de cada célula se pinta con imágenes ya preparadas (escribir texto en cada
  célula era lo más caro del dibujo), con la cámara lejos las bolitas se pintan sin halo, mirando (menú o
  espectador) no se acumulan más de 2 pasos por fotograma y el fondo del menú se pinta a la mitad en móviles
  lentos. En un móvil simulado 4 veces más lento: menú de Ultra de ~5 a ~33 FPS, espectador en Normal ~44 FPS.
- **Virus en Ultra:** cuando faltan muchos reaparecen más deprisa (antes el mapa se iba quedando sin virus).
- **Volumen x3:** el volumen general es el triple que antes, con un limitador para que no distorsione.
- **Bots con número:** en vez de nombre, cada bot se llama por su número (#1, #2… #200) y lo conserva al
  reaparecer.
- **Movimiento de los bots más suave:** giran con inercia en vez de cambiar de rumbo en seco (el giro medio
  baja un 34 % y los giros bruscos se reducen a la mitad, sin perder rendimiento en combate).
- **Partida nueva:** al pulsar Jugar desde el menú todos empiezan de cero (bots incluidos). Si mueres y pulsas «Jugar de nuevo», la partida no se reinicia: los bots conservan su progreso y tú reapareces con la masa inicial.
- **Unión automática:** las piezas de una célula dividida (de jugador y de bots) se juntan solas, con suavidad, a los 30 s. En el panel de la izquierda aparece la cuenta atrás «Unión en 0:xx». Dividir, expulsar masa o explotar contra un virus reinician la cuenta atrás de todas tus piezas.
- **Teclado propio del juego (móvil y tableta):** al tocar el apodo se abre un teclado del juego en vez del del móvil, así que nada se encoge ni se queda en negro (tampoco en pantalla completa). QWERTY español con **Ñ**; mantén pulsada una vocal para los acentos (á é í ó ú ü…) o una tecla de arriba para su número; mayúscula automática al empezar cada palabra y doble toque en ⇧ para bloquearla; páginas de números y símbolos (?123, =\<); mantener ⌫ borra seguido; vista previa de cada tecla, vibración y sonido suaves; contador 0/15. ✓, la flecha o tocar fuera lo cierran. En PC se usa el teclado normal.
- **Comer:** una célula que puede comerte (≥25 % más masa) lo hace cuando te tapa aproximadamente la mitad
  de tu superficie, como en el Agar.io original. Antes podía taparte entre el 65 % y el 74 % sin comerte.
  Lo mismo vale para explotar al pasar sobre un virus.
- **Colisiones:** las células grandes ya no atraviesan los muros (antes podían quedar casi a medias fuera
  de la arena) y, si crecen pegadas a uno, se desplazan hacia dentro con suavidad. Entre jugadores distintos (bots y
  jugador) **no hay choques**: solo cuenta comer; las células que no pueden comerse se atraviesan. Al dividirse un gigante o explotar con un virus, las piezas se
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
