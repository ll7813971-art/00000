# Super Obby Pro (Roblox Studio)

Un solo Script que construye un obby completo de **15 etapas + meta** cuando le das a Play.

## Instalación

1. En Roblox Studio: clic derecho en **ServerScriptService** → *Insert Object* → **Script**
   (un Script normal, no un LocalScript).
2. Pega todo el contenido de [`ServerScriptService/SuperObby.server.lua`](ServerScriptService/SuperObby.server.lua).
3. Dale a **Play**. El obby aparece en `Workspace/SuperObby`.

Para que se guarde el progreso en Studio: *Game Settings → Security →
Enable Studio Access to API Services* (el juego tiene que estar publicado).

## Etapas

| # | Etapa | Mecánica |
|---|-------|----------|
| 1 | Saltos Clásicos | Plataformas en zigzag que van subiendo |
| 2 | Piso de Lava | Piedras sobre lava mortal |
| 3 | Plataformas Móviles | Tres plataformas que van y vienen y un ascensor |
| 4 | Aspas Giratorias | Aspas láser que hay que saltar (la última es una cruz) |
| 5 | Bloques que Desaparecen | Parpadean y se caen al pisarlos |
| 6 | Cintas Locas | Cintas que empujan hacia atrás y a los lados |
| 7 | Trampolines | Impulsos hacia plataformas más altas |
| 8 | Cuerda Floja | Vigas cada vez más finas |
| 9 | Torre de Escalada | Dos escaleras de truss |
| 10 | Pasillo Láser | Láseres que se encienden y se apagan |
| 11 | Péndulos | Bolas gigantes que se balancean |
| 12 | Pista de Hielo | Plataformas inclinadas y resbaladizas |
| 13 | Súper Velocidad | Plataformas turbo y huecos largos |
| 14 | ¿Cuál es Real? | En cada fila solo una plataforma es real (tiene chispas) |
| 15 | Espiral al Cielo | Escalera de caracol de colores sobre lava |
| 16 | Meta | Trofeo, confeti y plataforma para volver a empezar |

## Extras

- Checkpoints con anti-salto, efecto de partículas y sonido.
- `leaderstats`: **Etapa** y **Victorias**.
- HUD con la etapa, la barra de progreso y avisos.
- Cronómetro por vuelta con récord personal.
- Guardado con DataStore (con reintentos, guardado automático y al cerrar el servidor).
- Vacío mortal bajo todo el obby.

Todo lo ajustable (posición, semilla, anti-salto, guardado, iluminación…) está en la tabla `CONFIG` al principio del script.
