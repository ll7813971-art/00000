# Retro Odyssey — nivel para Geometry Dash 2.209

Nivel completo de **7 minutos** (velocidad normal 1x) con decoración estilo **1.0**:
bloques con contorno, pinchos y colores vivos que cambian en cada sección.

## Archivos

| Archivo | Uso |
|---------|-----|
| `RetroOdyssey.gdlvl` | El nivel (formato plist de GD, el mismo que `.gmd`). |
| `RetroOdyssey.gmd`   | Copia idéntica con extensión `.gmd`, por si tu importador solo acepta esa. |
| `generador/generar_nivel.py` | Script que genera el nivel y comprueba que se puede pasar. |

Importar: con el mod **GDShare** (Geode) en el editor → *Import* → elige el archivo.

## Recorrido (16 secciones: cada una con su tema, velocidad, decoración y colores)

| Tiempo | Velocidad | Sección |
|--------|-----------|---------|
| 0:00 | 1x   | Cubo: homenaje a Stereo Madness, peldaños de medio bloque (techo con almenas) |
| 0:23 | 1x   | Cubo: escaleras y mesetas (techo escalonado) |
| 0:50 | 1x   | Nave: cueva amplia |
| 1:18 | 2x   | Cubo: carrera rápida de pinchos y bloques (techo con dientes) |
| 1:44 | 1x   | Bola: pasillo con desniveles |
| 2:10 | 0.5x | Cubo: castillo lento de pilares, pozos y plataformas (techo de arcos) |
| 2:39 | 1x   | UFO: túnel ondulado |
| 3:05 | 1x   | Cubo con gravedad invertida |
| 3:30 | 2x   | Nave: zigzag rápido |
| 3:56 | 1x   | Cubo: trampolines amarillos (techo liso con pinchos) |
| 4:23 | 1x   | Bola: desniveles dobles |
| 4:47 | 1x   | UFO: zigzag con islas y pinchos |
| 5:12 | 1x   | Cubo: orbes amarillos sobre pozos |
| 5:38 | 1x   | Nave: tramo estrecho con islas |
| 6:04 | 2x   | Cubo: gran final rápido con todo mezclado |
| 6:33 | 0.5x | Cubo: despedida tranquila y fundido a oscuro |

## Monedas estrella (3)

Son las monedas doradas de los niveles oficiales (objeto 142), no las monedas de usuario.

| Tiempo | Dónde |
|--------|-------|
| ~0:30 | Flotando sobre las escaleras (rosa): salta desde lo alto en el momento justo. |
| ~2:34 | Sobre los pilares del castillo lento (celeste). |
| ~6:25 | En el gran final rápido, en lo alto de una torre. |

El simulador comprueba que cada moneda se puede coger sin morir y terminar la sección.

## Objetos de la 1.0 que usa

Bloque (1), pincho (8), pinchos de suelo de los pozos (9), medio bloque / peldaño (40),
trampolín amarillo (35), orbe amarillo (36), portales de cubo, nave, gravedad y velocidad,
y colores de fondo y suelo. Todos van en el centro de su casilla, igual que los coloca el
editor (el propio juego dibuja el peldaño arriba y los pinchos de suelo y el trampolín abajo).

## Detalles y decoración

- Peldaños de medio bloque flotando sobre pinchos, como los de Stereo Madness (objeto 40).
- Trampolines amarillos que lanzan a torres de 3 bloques o por encima de pozos largos.
- Pozos con los pinchos de suelo clásicos.
- Techos colgantes estilo 1.0 sobre las partes de cubo (almenas, arcos, escalones y filas de
  pinchos colgando), a solo 4–5 bloques sobre el suelo para que se vean en pantalla. Cada
  techo se prueba con el simulador y, si estorba al salto, se sube un bloque.
- En el cubo invertido, techo grueso y suelo dentado de bloques y pinchos.
- Islas de bloques (a veces con pinchos) dentro de los túneles de nave y UFO.
- Dos cambios de color por sección: al entrar y otro a mitad (fondo más oscuro y suelo más
  claro); al final el nivel se funde a oscuro.
- Obstáculos casi seguidos: ritmos de pinchos, plataformas a distintas alturas, pilares,
  orbes dobles sobre pozos largos, mesetas con pinchos y pasillos de bola con pinchos dobles.

## Jugabilidad

- Ningún fragmento se repite: cada trozo se registra y, si ya existía, se genera otro.
- Las secciones de cubo y bola se comprueban con un simulador de física (240 fps, con dos
  juegos de parámetros de salto y hitboxes de pinchos agrandadas para dejar margen): cada
  fragmento se prueba al colocarlo y después la sección entera con la decoración puesta.
  Si algo no se puede pasar, se cambia por otro fragmento.
- Nave y UFO: siempre queda un camino continuo de al menos 3 bloques (nave) o 4 (UFO) de alto.
- Las salidas de nave/UFO tienen dos portales de cubo apilados para no poder esquivarlos.

## Música

El nivel trae la canción oficial por defecto. Para que la música dure lo mismo que el nivel,
pon en el editor una canción de Newgrounds de unos 7 minutos.

## Regenerar

```
python3 generador/generar_nivel.py
```
