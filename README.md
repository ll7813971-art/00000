# consola

Mod para Claude Code: `/run <lenguaje> <código>` ejecuta código y muestra la salida.

Lenguajes: python, js, ts, bash, ruby, php, perl, go, c, cpp, rust, java.

Ejemplos:
- `/run python print(2**10)`
- `/run sh ls -la`
- `/run c #include <stdio.h>
int main(){puts("hola");}`

Uso local: `claude --plugin-dir ./consola`
