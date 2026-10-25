#!/usr/bin/env python3
"""Generador del nivel "Retro Odyssey" para Geometry Dash 2.209.

Crea un nivel de ~7 minutos (velocidad normal 1x) con decoración estilo 1.0
(bloques con contorno y pinchos), cambios de color de fondo y suelo en cada
sección y modos cubo, nave, bola, UFO y cubo con gravedad invertida.

Cada parte del recorrido se comprueba con un simulador de física sencillo
(con hitboxes de pinchos agrandadas para dejar margen al jugador). Si una
sección no se puede pasar, se vuelve a generar. Ningún fragmento se repite.

Uso:  python3 generador/generar_nivel.py   ->  escribe RetroOdyssey.gdlvl y .gmd
"""
import base64
import gzip
import os
import random

# ---------------------------------------------------------------- constantes
CELL = 30.0
SPEED = 311.58                       # unidades/segundo a velocidad 1x
DURACION = 7 * 60                    # segundos
TOTAL_COLS = round(DURACION * SPEED / CELL)

ID_BLOQUE, ID_PINCHO, ID_ORBE = 1, 8, 36
ID_GRAV_NORMAL, ID_GRAV_INVERTIDA = 10, 11
ID_CUBO, ID_NAVE, ID_BOLA, ID_UFO = 12, 13, 47, 111
ID_COLOR = 899

CH_FONDO, CH_SUELO, CH_LINEA, CH_SUELO2 = 1000, 1001, 1002, 1009


class Nivel:
    def __init__(self):
        self.bloques = set()          # (col, fila)
        self.pinchos = {}             # (col, fila) -> rotación
        self.orbes = set()
        self.portales = []            # (col, fila, id)
        self.colores = []             # (col, canal, (r, g, b), duración)
        self.firmas = set()           # fragmentos usados (para no repetir)

    def copia_vacia(self):
        n = Nivel()
        n.firmas = self.firmas
        return n

    def fusionar(self, otro):
        self.bloques |= otro.bloques
        self.pinchos.update(otro.pinchos)
        self.orbes |= otro.orbes
        self.portales += otro.portales
        self.colores += otro.colores

    def unico(self, firma):
        if firma in self.firmas:
            return False
        self.firmas.add(firma)
        return True


# ------------------------------------------------------------------ simulador
class Sim:
    """Simulador de cubo/bola por fotogramas (240 fps) con búsqueda de entradas."""

    def __init__(self, nivel, altura_salto, tiempo_salto, factor_bola):
        self.lv = nivel
        self.G = 8 * altura_salto / tiempo_salto ** 2
        self.V0 = 4 * altura_salto / tiempo_salto
        self.Gb = self.G * factor_bola
        self.dt = 1 / 240

    def solido(self, c, r):
        return (c, r) in self.lv.bloques

    def choca_pincho(self, x, y):
        c0, c1 = int((x - 30) // CELL), int((x + 30) // CELL)
        for c in range(c0, c1 + 1):
            for r in range(int((y - 30) // CELL), int((y + 30) // CELL) + 1):
                if (c, r) in self.lv.pinchos:
                    cx, cy = c * CELL + 15, r * CELL + 15
                    # hitbox real ~6x12; usamos 14x20 para dejar margen
                    if abs(x - cx) < 15 + 7 and abs(y - cy) < 15 + 10:
                        return True
        return False

    def orbe_cerca(self, x, y):
        for c in range(int((x - 30) // CELL), int((x + 30) // CELL) + 1):
            for r in range(int((y - 30) // CELL), int((y + 30) // CELL) + 1):
                if (c, r) in self.lv.orbes:
                    cx, cy = c * CELL + 15, r * CELL + 15
                    # orbe más pequeño de lo real: exige más precisión
                    if abs(x - cx) < 15 + 8 and abs(y - cy) < 15 + 8:
                        return (c, r)
        return None

    def paso(self, x, y, vy, s, suelo, modo):
        """Avanza un fotograma. Devuelve el nuevo estado o None si muere."""
        dt = self.dt
        g = self.G if modo == 'cubo' else self.Gb
        nx = x + SPEED * dt
        if suelo:
            # ¿sigue habiendo apoyo debajo?
            sop = self.apoyo(nx, y, s)
            if not sop:
                suelo = False
        if not suelo:
            vy -= s * g * dt
            vy = max(min(vy, 900), -900)
        ny = y + (0 if suelo else vy * dt)
        # suelo del mundo
        if ny < 15:
            if s > 0:
                ny, vy, suelo = 15, 0, True
            else:
                return None
        if ny > 2000:
            return None
        # bloques
        c0, c1 = int((nx - 15) // CELL), int((nx + 15 - 1e-6) // CELL)
        r0, r1 = int((ny - 15) // CELL), int((ny + 15 - 1e-6) // CELL)
        for c in range(c0, c1 + 1):
            for r in range(r0, r1 + 1):
                if not self.solido(c, r):
                    continue
                top, bot = (r + 1) * CELL, r * CELL
                if s > 0 and vy <= 0 and (y - 15) >= top - 4:
                    ny, vy, suelo = top + 15, 0, True
                elif s < 0 and vy >= 0 and (y + 15) <= bot + 4:
                    ny, vy, suelo = bot - 15, 0, True
                else:
                    return None
        # comprobación final tras ajustar
        c0, c1 = int((nx - 15) // CELL), int((nx + 15 - 1e-6) // CELL)
        r0, r1 = int((ny - 15 + 0.01) // CELL), int((ny + 15 - 0.01) // CELL)
        for c in range(c0, c1 + 1):
            for r in range(r0, r1 + 1):
                if self.solido(c, r):
                    return None
        if self.choca_pincho(nx, ny):
            return None
        return nx, ny, vy, s, suelo

    def apoyo(self, x, y, s):
        if s > 0 and abs(y - 15) < 0.01:
            return True
        fila = (y - 15 - 1) // CELL if s > 0 else (y + 15 + 1) // CELL
        c0, c1 = int((x - 15) // CELL), int((x + 15 - 1e-6) // CELL)
        borde = (y - 15) if s > 0 else (y + 15)
        for c in range(c0, c1 + 1):
            if self.solido(c, int(fila)):
                cara = (fila + 1) * CELL if s > 0 else fila * CELL
                if abs(cara - borde) < 0.5:
                    return True
        return False

    def jugable(self, col_ini, col_fin, modo_inicial='cubo'):
        x = col_ini * CELL + 15
        estados = {(round(15.0, 2), 0.0, 1, True, None, modo_inicial)}
        reales = {(15.0, 0.0, 1, True, None, modo_inicial)}
        portales = sorted((c * CELL + 15, pid) for c, _, pid in self.lv.portales
                          if col_ini <= c < col_fin)
        cuadro = 0
        while x < col_fin * CELL:
            cuadro += 1
            decide = cuadro % 4 == 0      # el jugador decide a 60 fps
            nuevos = {}
            for (y, vy, s, suelo, orbe, modo) in reales:
                opciones = [(vy, s, suelo, orbe)]
                if suelo and decide:
                    if modo == 'cubo':
                        opciones.append((s * self.V0, s, False, orbe))
                    else:
                        opciones.append((0.0, -s, False, orbe))
                elif modo == 'cubo' and decide and not suelo:
                    o = self.orbe_cerca(x, y)
                    if o and o != orbe:
                        opciones.append((s * self.V0, s, False, o))
                for (v2, s2, g2, o2) in opciones:
                    r = self.paso(x, y, v2, s2, g2 and v2 == 0, modo)
                    if r is None:
                        continue
                    nx, ny, nvy, ns, nsuelo = r
                    nmodo = modo
                    for px, pid in portales:
                        if x < px <= nx:
                            if pid == ID_GRAV_INVERTIDA:
                                ns, nsuelo = -1, False
                            elif pid == ID_GRAV_NORMAL:
                                ns = 1
                                nsuelo = nsuelo and ns == s2
                            elif pid == ID_BOLA:
                                nmodo = 'bola'
                            elif pid == ID_CUBO:
                                nmodo = 'cubo'
                    clave = (round(ny, 0), round(nvy / 10), ns, nsuelo, o2, nmodo)
                    if clave not in nuevos:
                        nuevos[clave] = (ny, nvy, ns, nsuelo, o2, nmodo)
            if not nuevos:
                return False
            reales = list(nuevos.values())
            if len(reales) > 150:
                reales.sort()
                reales = reales[::len(reales) // 150 + 1]
            x += SPEED * self.dt
        return True


PARAMETROS_FISICA = [(58, 0.37, 0.55), (70, 0.41, 0.75)]


def comprobar(nivel_seccion, ini, fin, modo='cubo'):
    return all(Sim(nivel_seccion, h, t, fb).jugable(ini, fin, modo)
               for h, t, fb in PARAMETROS_FISICA)


# ------------------------------------------------------- secciones de cubo
class Terreno:
    """Columna a columna: altura del terreno + pinchos/orbes encima."""

    def __init__(self, lv, col, espejo=False):
        self.lv, self.col, self.h, self.espejo = lv, col, 0, espejo

    def fila(self, r):
        return 4 - r if self.espejo else r

    def columna(self, h=None, pincho=False, pozo=False, orbe=None):
        h = self.h if h is None else h
        for r in range(h):
            self.lv.bloques.add((self.col, self.fila(r)))
        if self.espejo:
            self.lv.bloques.add((self.col, 5))           # techo base
        if pincho:
            self.lv.pinchos[(self.col, self.fila(h))] = 180 if self.espejo else 0
        if pozo:
            self.lv.pinchos[(self.col, self.fila(0))] = 180 if self.espejo else 0
        if orbe is not None:
            self.lv.orbes.add((self.col, self.fila(orbe)))
        self.col += 1

    def plano(self, n):
        for _ in range(n):
            self.columna()


def trozo_cubo(t, rng, tipo, hmax):
    """Añade un fragmento jugable; devuelve su firma (para evitar repetición)."""
    h, firma = t.h, [tipo, t.h]
    if tipo == 'pincho':
        k = rng.choice([1, 1, 2])
        pre, post = rng.randint(3, 5), rng.randint(4, 7)
        t.plano(pre)
        for _ in range(k):
            t.columna(pincho=True)
        t.plano(post)
        firma += [k, pre, post]
    elif tipo == 'subir' and h < hmax:
        largo = rng.randint(4, 8)
        t.plano(2)
        t.h += 1
        t.plano(largo)
        firma += [largo]
    elif tipo == 'bajar' and h > 0:
        caida = rng.randint(1, h)
        t.h -= caida
        largo = rng.randint(3, 6)
        t.plano(largo)
        firma += [caida, largo]
    elif tipo == 'pozo' and h >= 1:
        ancho = rng.choice([1, 2, 2])
        t.plano(2)
        for _ in range(ancho):
            t.columna(h=0, pozo=True)
        largo = rng.randint(4, 7)
        t.plano(largo)
        firma += [ancho, largo]
    elif tipo == 'bloque' and h == 0:
        ancho = rng.randint(1, 4)
        t.plano(3)
        for _ in range(ancho):
            t.columna(h=1)
        t.plano(rng.randint(4, 6))
        firma += [ancho]
    elif tipo == 'meseta' and h < hmax:
        # sube, pincho sobre la meseta, baja
        t.plano(3)
        t.h += 1
        a, b = rng.randint(3, 5), rng.randint(3, 5)
        t.plano(a)
        t.columna(pincho=True)
        t.plano(b)
        t.h -= 1
        t.plano(4)
        firma += [a, b]
    elif tipo == 'pilares' and h >= 1:
        n = rng.randint(2, 4)
        t.plano(2)
        for i in range(n):
            ancho = rng.choice([1, 2, 2])
            t.columna(h=0, pozo=True)
            if ancho == 2:
                t.columna(h=0, pozo=True)
            t.plano(rng.randint(2, 3))
            firma += [ancho]
        t.plano(3)
    elif tipo == 'orbe':
        pre = rng.randint(3, 4)
        t.plano(pre)
        pos = rng.choice([1, 2])
        for i in range(5):
            if t.h == 0:
                t.columna(pincho=True, orbe=(2 + t.h) if i == pos else None)
            else:
                t.columna(h=0, pozo=True, orbe=(2 + t.h) if i == pos else None)
        t.plano(6)
        firma += [pre, pos]
    elif tipo == 'escalera' and h + 2 <= hmax:
        l1, l2 = rng.randint(4, 5), rng.randint(4, 6)
        t.plano(2)
        t.h += 1
        t.plano(l1)
        t.h += 1
        t.plano(l2)
        firma += [l1, l2]
    elif tipo == 'pincho_bloque' and h == 0:
        # bloque bajo seguido de un pincho
        t.plano(3)
        t.columna(h=1)
        t.columna(h=1)
        t.plano(rng.randint(3, 4))
        t.columna(pincho=True)
        t.plano(5)
        firma += ['pb']
    else:
        return None
    firma.append(t.col % 7)
    return tuple(firma)


def seccion_cubo(lv, col, largo, rng, tipos, hmax, espejo=False):
    for intento in range(80):
        s = lv.copia_vacia()
        t = Terreno(s, col, espejo)
        if espejo:
            t.plano(1)
            s.portales.append((t.col, 1, ID_GRAV_INVERTIDA))
            t.plano(7)
        else:
            t.plano(14 if col == 0 else 6)       # inicio tranquilo
        firmas_local = []
        while t.col < col + largo - 14:
            antes = (t.col, t.h)
            tipo = rng.choice(tipos)
            # guardamos el estado por si el fragmento ya existe
            copia = (set(s.bloques), dict(s.pinchos), set(s.orbes))
            f = trozo_cubo(t, rng, tipo, hmax)
            if f is None or f in lv.firmas or f in firmas_local:
                s.bloques, s.pinchos, s.orbes = copia
                t.col, t.h = antes
                continue
            firmas_local.append(f)
        while t.h > 0:
            t.h -= 1
            t.plano(3)
        if espejo:
            t.plano(2)
            s.portales.append((t.col, 3, ID_GRAV_NORMAL))
            t.plano(3)
            t.espejo = False
        while t.col < col + largo:
            t.columna()
        if comprobar(s, col, col + largo):
            lv.firmas.update(firmas_local)
            lv.fusionar(s)
            return
    raise RuntimeError('no se pudo generar una sección de cubo jugable')


# ----------------------------------------------------------- nave y UFO
def tunel(lv, col, largo, rng, modo, hueco_min, cambio_cada, pinchos, onda):
    pid = ID_NAVE if modo == 'nave' else ID_UFO
    s = lv.copia_vacia()
    s.portales.append((col + 1, 1, pid))
    suelo, techo = 0, 9
    objetivo_s, objetivo_t = 1, 7
    ultimo_cambio = col
    fin_tunel = col + largo - 12
    firma_trozo = []
    c = col + 4
    while c < col + largo:
        if c < fin_tunel:
            if c - ultimo_cambio >= cambio_cada:
                if suelo == objetivo_s and techo == objetivo_t:
                    # nuevo objetivo para el hueco
                    hueco = rng.randint(hueco_min, hueco_min + 2)
                    base = rng.randint(0, 9 - hueco - 1) if onda == 'libre' else \
                        (0 if objetivo_s >= 3 else rng.randint(min(3, 9 - hueco), 9 - hueco))
                    objetivo_s, objetivo_t = base, base + hueco
                    firma_trozo.append((base, hueco))
                ms = (objetivo_s > suelo) - (objetivo_s < suelo)
                mt = (objetivo_t > techo) - (objetivo_t < techo)
                # mover primero el lado que abre el hueco
                if mt > 0 or ms < 0:
                    if mt > 0:
                        techo += 1
                    else:
                        suelo -= 1
                elif ms or mt:
                    if ms:
                        suelo += 1
                    else:
                        techo -= 1
                ultimo_cambio = c
        else:
            # embudo de salida
            if c - ultimo_cambio >= 1:
                if suelo > 0:
                    suelo -= 1
                elif techo < 6:
                    techo += 1
                elif techo > 6:
                    techo -= 1
                ultimo_cambio = c
        for r in range(suelo):
            s.bloques.add((c, r))
        for r in range(techo, 10):
            s.bloques.add((c, r))
        if pinchos and c < fin_tunel and techo - suelo >= hueco_min + 1 and rng.random() < 0.18:
            if rng.random() < 0.5 and suelo > 0:
                s.pinchos[(c, suelo)] = 0
            elif techo < 9:
                s.pinchos[(c, techo - 1)] = 180
        c += 1
    s.portales.append((col + largo - 3, 1, ID_CUBO))
    s.portales.append((col + largo - 3, 4, ID_CUBO))
    validar_tunel(s, col + 4, col + largo, hueco_min)
    firma = (modo, tuple(firma_trozo))
    if not lv.unico(firma):
        return False
    lv.fusionar(s)
    return True


def validar_tunel(s, ini, fin, hueco_min):
    previo = None
    for c in range(ini, fin):
        libres = [r for r in range(10) if (c, r) not in s.bloques
                  and (c, r) not in s.pinchos]
        if not libres:
            raise RuntimeError(f'columna cerrada en {c}')
        intervalo = (min(libres), max(libres))
        if intervalo[1] - intervalo[0] + 1 < min(hueco_min - 1, 4):
            raise RuntimeError(f'hueco demasiado pequeño en {c}')
        if previo:
            solape = min(previo[1], intervalo[1]) - max(previo[0], intervalo[0]) + 1
            if solape < 3:
                raise RuntimeError(f'cambio brusco en {c}')
        previo = intervalo


def seccion_tunel(lv, col, largo, rng, **kw):
    for _ in range(50):
        if tunel(lv, col, largo, rng, **kw):
            return
    raise RuntimeError('túnel repetido')


# ------------------------------------------------------------------ bola
def seccion_bola(lv, col, largo, rng, max_desnivel):
    for intento in range(80):
        s = lv.copia_vacia()
        s.portales.append((col + 1, 1, ID_BOLA))
        f = 0
        c = col + 3
        fin = col + largo - 10
        firma = ['bola']
        siguiente = c + 12
        while c < col + largo:
            if c < fin and c >= siguiente:
                opciones = ['pincho_suelo', 'pincho_techo']
                if f < max_desnivel:
                    opciones.append('subir')
                if f > 0:
                    opciones.append('bajar')
                ev = rng.choice(opciones)
                if ev == 'subir':
                    f += 1
                elif ev == 'bajar':
                    f -= 1
                elif ev == 'pincho_suelo':
                    s.pinchos[(c, f)] = 0
                else:
                    s.pinchos[(c, f + 2)] = 180
                firma.append((ev, f))
                siguiente = c + rng.randint(8, 11)
            if c >= fin and f > 0 and c >= siguiente:
                f -= 1
                siguiente = c + 8
            for r in range(f):
                s.bloques.add((c, r))
            if col + 6 <= c < col + largo - 4:
                for r in range(f + 3, f + 3 + 2):
                    s.bloques.add((c, r))
            c += 1
        s.portales.append((col + largo - 6, 1, ID_GRAV_NORMAL))
        s.portales.append((col + largo - 4, 1, ID_CUBO))
        if tuple(firma) in lv.firmas:
            continue
        if comprobar(s, col, col + largo):
            lv.firmas.add(tuple(firma))
            lv.fusionar(s)
            return
    raise RuntimeError('no se pudo generar una sección de bola jugable')


# ------------------------------------------------------------------ colores
PALETA = [  # (fondo, suelo) estilo 1.0: colores vivos y fondo claro/oscuro suave
    ((40, 125, 255), (0, 102, 255)),     # azul clásico (Stereo Madness)
    ((255, 0, 200), (180, 0, 255)),      # rosa
    ((125, 0, 255), (60, 0, 160)),       # morado nave
    ((0, 200, 120), (0, 150, 90)),       # verde
    ((255, 120, 0), (200, 70, 0)),       # naranja bola
    ((0, 170, 255), (0, 90, 200)),       # celeste
    ((255, 60, 60), (170, 0, 30)),       # rojo UFO
    ((70, 70, 160), (30, 30, 110)),      # azul noche (gravedad)
    ((200, 0, 255), (110, 0, 200)),      # violeta
    ((0, 210, 210), (0, 130, 150)),      # turquesa
    ((255, 190, 0), (210, 120, 0)),      # amarillo
    ((90, 200, 0), (40, 140, 0)),        # lima
    ((255, 80, 150), (190, 30, 100)),    # fresa
    ((40, 40, 220), (20, 20, 140)),      # azul intenso
    ((0, 140, 255), (255, 0, 140)),      # final: azul + rosa
    ((40, 125, 255), (0, 102, 255)),     # vuelta al azul clásico
]


def poner_colores(lv, col, i):
    fondo, suelo = PALETA[i % len(PALETA)]
    lv.colores.append((col, CH_FONDO, fondo, 1.2))
    lv.colores.append((col, CH_SUELO, suelo, 1.2))
    lv.colores.append((col, CH_SUELO2, suelo, 1.2))


# -------------------------------------------------------------------- nivel
def construir(semilla=2209):
    rng = random.Random(semilla)
    lv = Nivel()
    secciones = [
        ('cubo', 230, dict(tipos=['pincho', 'bloque', 'subir', 'bajar'], hmax=1)),
        ('cubo', 280, dict(tipos=['escalera', 'subir', 'bajar', 'pincho', 'meseta'], hmax=3)),
        ('nave', 300, dict(modo='nave', hueco_min=5, cambio_cada=3, pinchos=False, onda='libre')),
        ('cubo', 270, dict(tipos=['orbe', 'pincho', 'bloque', 'pincho_bloque'], hmax=1)),
        ('bola', 260, dict(max_desnivel=1)),
        ('cubo', 290, dict(tipos=['subir', 'pozo', 'pilares', 'bajar', 'escalera'], hmax=3)),
        ('ufo', 260, dict(modo='ufo', hueco_min=5, cambio_cada=4, pinchos=False, onda='libre')),
        ('espejo', 260, dict(tipos=['pincho', 'subir', 'bajar', 'pozo'], hmax=1)),
        ('nave', 300, dict(modo='nave', hueco_min=4, cambio_cada=2, pinchos=True, onda='zigzag')),
        ('cubo', 280, dict(tipos=['meseta', 'pincho_bloque', 'pozo', 'subir', 'bajar', 'pincho'], hmax=2)),
        ('bola', 250, dict(max_desnivel=2)),
        ('ufo', 260, dict(modo='ufo', hueco_min=5, cambio_cada=3, pinchos=True, onda='zigzag')),
        ('cubo', 280, dict(tipos=['orbe', 'escalera', 'pilares', 'bajar', 'pozo'], hmax=3)),
        ('nave', 280, dict(modo='nave', hueco_min=4, cambio_cada=2, pinchos=True, onda='libre')),
        ('cubo', 300, dict(tipos=['pincho', 'meseta', 'orbe', 'pilares', 'subir', 'bajar',
                                  'pincho_bloque', 'escalera'], hmax=2)),
    ]
    usado = sum(l for _, l, _ in secciones)
    secciones.append(('cubo', TOTAL_COLS - usado,
                      dict(tipos=['bloque', 'pincho', 'subir', 'bajar'], hmax=1)))

    col = 0
    for i, (tipo, largo, kw) in enumerate(secciones):
        poner_colores(lv, max(col - 4, 0), i)
        sub = random.Random(rng.random())
        if tipo == 'cubo':
            seccion_cubo(lv, col, largo, sub, **kw)
        elif tipo == 'espejo':
            seccion_cubo(lv, col, largo, sub, espejo=True, **kw)
        elif tipo in ('nave', 'ufo'):
            seccion_tunel(lv, col, largo, sub, **kw)
        elif tipo == 'bola':
            seccion_bola(lv, col, largo, sub, **kw)
        print(f'sección {i + 1:2d} {tipo:6s} columnas {col:4d}-{col + largo:4d} '
              f'({col * CELL / SPEED / 60:4.2f}-{(col + largo) * CELL / SPEED / 60:4.2f} min) OK')
        col += largo
    # final: el fondo se apaga suavemente al llegar a la meta
    lv.colores.append((col - 12, CH_FONDO, (10, 10, 40), 2.0))
    lv.colores.append((col - 12, CH_SUELO, (0, 0, 0), 2.0))
    lv.colores.append((col - 12, CH_SUELO2, (0, 0, 0), 2.0))
    return lv, col


# ------------------------------------------------------------ exportación
def cadena_nivel(lv):
    def color(canal, rgb):
        r, g, b = rgb
        return f'1_{r}_2_{g}_3_{b}_11_255_12_255_13_255_4_-1_6_{canal}_7_1_15_1_18_0_8_1'

    fondo, suelo = PALETA[0]
    canales = [color(CH_FONDO, fondo), color(CH_SUELO, suelo), color(CH_SUELO2, suelo),
               color(CH_LINEA, (255, 255, 255)), color(1004, (255, 255, 255))]
    cab = ('kS38,' + '|'.join(canales) + '|,kA13,0,kA15,0,kA16,0,kA14,,kA6,0,kA7,0,'
           'kA25,0,kA17,0,kA18,0,kS39,0,kA2,0,kA3,0,kA8,0,kA4,0,kA9,0,kA10,0,kA11,0')
    objs = []

    def pos(c, r):
        return f'2,{c * CELL + 15:g},3,{r * CELL + 15:g}'

    for (c, r) in sorted(lv.bloques):
        objs.append(f'1,{ID_BLOQUE},{pos(c, r)}')
    for (c, r), rot in sorted(lv.pinchos.items()):
        objs.append(f'1,{ID_PINCHO},{pos(c, r)}' + (f',6,{rot}' if rot else ''))
    for (c, r) in sorted(lv.orbes):
        objs.append(f'1,{ID_ORBE},{pos(c, r)}')
    for c, r, pid in sorted(lv.portales):
        objs.append(f'1,{pid},{pos(c, r)}')
    for c, canal, (r, g, b), dur in lv.colores:
        objs.append(f'1,{ID_COLOR},{pos(c, 14)},7,{r},8,{g},9,{b},10,{dur},23,{canal},35,1')
    texto = cab + ';' + ';'.join(objs) + ';'
    comp = gzip.compress(texto.encode(), compresslevel=6, mtime=0)
    return base64.urlsafe_b64encode(comp).decode(), len(objs)


def plist(nombre, datos, descripcion):
    desc = base64.urlsafe_b64encode(descripcion.encode()).decode()
    return ('<?xml version="1.0"?><plist version="1.0" gjver="2.0"><dict>'
            '<k>kCEK</k><i>4</i>'
            f'<k>k2</k><s>{nombre}</s>'
            f'<k>k3</k><s>{desc}</s>'
            f'<k>k4</k><s>{datos}</s>'
            '<k>k5</k><s>Player</s>'
            '<k>k13</k><t/><k>k21</k><i>2</i><k>k16</k><i>1</i>'
            '<k>k8</k><i>0</i>'
            '<k>k50</k><i>45</i><k>k47</k><t/>'
            '</dict></plist>')


def main():
    lv, cols = construir()
    datos, n = cadena_nivel(lv)
    desc = ('Retro Odyssey: 7 minutos de aventura estilo 1.0 con cubo, nave, bola, '
            'UFO y gravedad invertida. Cada seccion tiene sus propios colores.')
    xml = plist('Retro Odyssey', datos, desc)
    raiz = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    for ext in ('gdlvl', 'gmd'):
        with open(os.path.join(raiz, f'RetroOdyssey.{ext}'), 'w') as f:
            f.write(xml)
    print(f'{n} objetos, {cols} columnas = {cols * CELL / SPEED:.1f} s '
          f'({cols * CELL / SPEED / 60:.2f} min)')


if __name__ == '__main__':
    main()
