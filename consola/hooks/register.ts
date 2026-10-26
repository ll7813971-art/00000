import type { Register } from 'claude-code'

const DIR = '/tmp/consola'

// file name, then the command that runs it (FILE is replaced by its path)
const LANGS: Record<string, { file: string; cmd: string }> = {
  python: { file: 'main.py', cmd: 'python3 FILE' },
  js: { file: 'main.js', cmd: 'node FILE' },
  ts: { file: 'main.ts', cmd: 'node --experimental-strip-types FILE' },
  bash: { file: 'main.sh', cmd: 'bash FILE' },
  ruby: { file: 'main.rb', cmd: 'ruby FILE' },
  php: { file: 'main.php', cmd: 'php FILE' },
  perl: { file: 'main.pl', cmd: 'perl FILE' },
  go: { file: 'main.go', cmd: 'go run FILE' },
  c: { file: 'main.c', cmd: 'gcc FILE -o /tmp/consola/a.out -lm && /tmp/consola/a.out' },
  cpp: { file: 'main.cpp', cmd: 'g++ FILE -o /tmp/consola/a.out && /tmp/consola/a.out' },
  rust: { file: 'main.rs', cmd: 'rustc FILE -o /tmp/consola/r.out && /tmp/consola/r.out' },
  java: { file: 'Main.java', cmd: 'java FILE' },
}
const ALIASES: Record<string, string> = {
  py: 'python', javascript: 'js', node: 'js', typescript: 'ts', sh: 'bash',
  rb: 'ruby', 'c++': 'cpp', rs: 'rust',
}

const HELP =
  'Uso: /run <lenguaje> <código>  (o /run sh <comando> para la consola)\n' +
  'Lenguajes: ' + Object.keys(LANGS).join(', ')

export const register: Register = on => {
  on('session.start', async ($, e, next) => {
    await $.command.register({
      name: 'run',
      description: 'Ejecuta código en cualquier lenguaje: /run python print(1)',
    })
    return next(e)
  })

  on('command.run', { command: 'run' }, async ($, e) => {
    const m = e.args.match(/^\s*(\S+)\s+([\s\S]+)$/)
    if (!m) return { text: HELP }
    const name = ALIASES[m[1].toLowerCase()] ?? m[1].toLowerCase()
    const lang = LANGS[name]
    if (!lang) return { text: `Lenguaje desconocido: ${m[1]}\n${HELP}` }

    const path = `${DIR}/${lang.file}`
    await $.process.run(['mkdir', '-p', DIR])
    await $.fs.write(path, m[2])
    const r = await $.process.run(['bash', '-c', lang.cmd.replace('FILE', path)], {
      timeoutMs: 60000,
    })
    const out = (r.stdout + r.stderr).trimEnd() || '(sin salida)'
    return { text: `[${name}] exit ${r.exitCode}\n${out}` }
  })
}
