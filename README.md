# CuboVerso

Un Minecraft 3D sencillo que se juega en el navegador, **siempre en modo creativo**.

**Cómo jugar:** descarga `CuboVerso.html` (un solo archivo con todo dentro) y ábrelo en Chrome, Edge, Firefox o Safari.
Funciona en **PC** (teclado y ratón) y en **móvil/tablet** (joystick y botones táctiles); cambia solo según uses los dedos o el ratón.
Botón **⛶ Pantalla completa** en el menú, arriba a la derecha y en los controles táctiles (o F11). En iPhone: Compartir → «Añadir a pantalla de inicio».

Para programar: el código está en `index.html` (usa `lib/three.min.js`); `CuboVerso.html` se genera con `python3 empaquetar.py`.

## Qué tiene de diferente
- Mundo infinito con **islas flotantes**, un **Bosque místico** con hongos gigantes que brillan y cristales, desiertos, tundra nevada, bosques y montañas.
- Día y noche con sol, luna, estrellas y nubes; los faroles, cristales, hongos y calabazas brillan de noche.
- Criaturas: cerdos, ovejas de colores (click derecho para cambiarles el color), gallinas que planean, slimes que saltan y se dividen al morir, pájaros que vuelan en círculos y **Chispa**, una mascota que te sigue.
- Bloques especiales: **TNT** (golpéala y explota, con reacción en cadena), **Bloque rebote**, **Pista veloz**, **Hielo** que resbala.
- Herramientas mágicas: **Cañón de TNT**, **Varita de vida** (hace crecer el árbol que toque según el suelo), **Pincel arcoíris** y **Bastón meteoro**.
- **Criaturas con inteligencia y pathfinding (A\*)**: buscan rutas rodeando paredes, suben escalones saltando, bajan hasta 3 bloques, evitan cactus y agua.
  Huyen de la TNT encendida y de ti si las golpeas, van en manada, salen del agua hacia la orilla, de noche descansan más y te miran cuando estás cerca.
  Con su comida en la mano (zanahoria → cerdos, trigo → ovejas, semillas → gallinas) te siguen; dásela a dos y se enamoran y **tienen una cría** que sigue a su madre y crece.
  Los slimes son curiosos y te persiguen saltando; Chispa calcula rutas por el aire, te avisa de la TNT y, si te quedas quieto, explora y te enseña minerales y cristales cercanos.
  Pulsa **P** (o activa «Ver rutas» en el menú) para ver las rutas que calcula cada criatura, y apunta a una para ver qué está haciendo.
- Cámara en primera persona, tercera persona y vista frontal (tecla V), con tu personaje animado.

## Controles (teclado y ratón)
| Tecla | Acción |
|---|---|
| WASD · ratón | moverse · mirar |
| Espacio | saltar (doble toque = volar) |
| Shift | bajar volando / andar despacio |
| Ctrl o doble W | correr |
| Click izquierdo | romper bloque / golpear criatura / encender TNT |
| Click derecho | poner bloque / usar huevo o herramienta / acariciar criatura |
| Click de la rueda | copiar el bloque que miras |
| 1-9 · rueda | elegir hueco |
| E | inventario creativo |
| V | cambiar cámara |
| F | volar sí/no |
| T (mantener) | acelerar el tiempo |
| P | ver las rutas de las criaturas |
| F11 | pantalla completa |

Cada partida es un mundo nuevo. Para repetir uno, abre `index.html?semilla=1234`.
