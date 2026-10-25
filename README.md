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

## Recorrido (16 secciones, cada una con su color de fondo y suelo)

| Tiempo | Sección |
|--------|---------|
| 0:00 | Cubo: introducción tranquila (azul clásico) |
| 0:22 | Cubo: escaleras y mesetas (rosa) |
| 0:49 | Nave: cueva amplia (morado) |
| 1:18 | Cubo: orbes amarillos sobre pozos (verde) |
| 1:44 | Bola: pasillo con desniveles (naranja) |
| 2:09 | Cubo: pilares y pozos tipo castillo (celeste) |
| 2:37 | UFO: túnel ondulado (rojo) |
| 3:02 | Cubo con gravedad invertida (azul noche) |
| 3:27 | Nave: zigzag con pinchos (violeta) |
| 3:56 | Cubo: mezcla de mesetas y pozos (turquesa) |
| 4:23 | Bola: desniveles dobles (amarillo) |
| 4:47 | UFO: zigzag con pinchos (lima) |
| 5:12 | Cubo: torres y orbes (fresa) |
| 5:39 | Nave: tramo final estrecho (azul intenso) |
| 6:06 | Cubo: gran final (azul + rosa) |
| 6:35 | Cubo: despedida tranquila y fundido a oscuro |

## Detalles y decoración

- Peldaños de medio bloque flotando sobre pinchos, como los de Stereo Madness (objeto 40).
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
