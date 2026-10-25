"""Genera CuboVerso.html: el juego en un solo archivo, con Three.js incluido."""
src = open('index.html', encoding='utf-8').read()
lib = open('lib/three.min.js', encoding='utf-8').read()
tag = '<script src="lib/three.min.js"></script>'
assert tag in src
open('CuboVerso.html', 'w', encoding='utf-8').write(src.replace(tag, '<script>' + lib + '</script>'))
print('CuboVerso.html listo')
