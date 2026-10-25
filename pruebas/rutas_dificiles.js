const { chromium } = require('playwright');
(async () => {
  const b = await chromium.launch({args:['--use-gl=angle','--use-angle=swiftshader','--enable-unsafe-swiftshader']});
  const p = await b.newPage({viewport:{width:400,height:300}});
  const errs=[]; p.on('pageerror',e=>errs.push(e.message+' @ '+(e.stack||'').split('\n')[1]));
  await p.goto('file://' + require('path').resolve(__dirname, '../index.html') + '?semilla=42');
  await p.waitForFunction(()=>document.getElementById('status').textContent.startsWith('Mundo listo'),null,{timeout:60000});
  await p.waitForTimeout(4000);
  const r = await p.evaluate(() => {
    const out = {};
    const realThink = think, realThinkSlime = thinkSlime;
    window.think = () => {}; window.thinkSlime = () => {};
    for (const e of entities) if (e.wild) e.remove();
    const P = player.pos, X = Math.floor(P.x) + 30, Z = Math.floor(P.z), Y = 40;
    // plataforma plana con laberinto encima
    for (let x = -1; x <= 16; x++) for (let z = -1; z <= 16; z++) { setBlock(X + x, Y - 1, Z + z, B.stone); for (let y = 0; y < 5; y++) setBlock(X + x, Y + y, Z + z, 0); }
    const maze = [
      '################',
      '#S.....#.......#',
      '#.####.#.#####.#',
      '#.#....#.#...#.#',
      '#.#.####.#.#.#.#',
      '#.#......#.#...#',
      '#.########.###.#',
      '#..........#...#',
      '##########.#.###',
      '#..........#...#',
      '#.##########.#.#',
      '#............#G#',
      '################'];
    maze.forEach((row, z) => [...row].forEach((c, x) => { if (c === '#') { setBlock(X + x, Y, Z + z, B.brick); setBlock(X + x, Y + 1, Z + z, B.brick); setBlock(X + x, Y + 2, Z + z, B.brick); } }));
    // escalera: 4 escalones
    for (let i = 0; i < 4; i++) for (let j = 0; j <= i; j++) setBlock(X + 14, Y + j, Z + 14 - 0, 0);
    const run = (type, opts, start, goal, steps, mid) => {
      const e = new Mob(type, start[0] + 0.5, start[1], start[2] + 0.5, opts);
      pathBudget = 99999;
      goTo(e, new THREE.Vector3(goal[0] + 0.5, goal[1], goal[2] + 0.5), 0.5);
      const len = e.path ? e.path.length : 0;
      let ok = false, s = 0;
      for (; s < steps; s++) {
        pathBudget = 99999; e.age += 0.05; e.thinkT = 99;
        if (mid && s === 40) mid(e);
        if (s % 8 === 0) checkPath(e);
        if (type === 'slime') updateSlime(e, 0.05); else updateGround(e, 0.05);
        if (Math.hypot(e.pos.x - goal[0] - 0.5, e.pos.z - goal[2] - 0.5) < 1.2 && Math.abs(e.pos.y - goal[1]) < 1.5) { ok = true; break; }
      }
      const res = { ok, secs: +(s * 0.05).toFixed(1), pathLen: len, end: e.pos.toArray().map(v => +v.toFixed(1)) };
      e.remove();
      return res;
    };
    const S = [X + 1, Y, Z + 1], G = [X + 14, Y, Z + 11];
    for (const [t, o] of [['pig', {}], ['sheep', {}], ['chicken', {}], ['slime', { size: 0.6 }], ['slime', { size: 1.2 }], ['pig', { baby: true }]])
      out['laberinto ' + t + (o.size ? o.size : '') + (o.baby ? ' cría' : '')] = run(t, o, S, G, 1600);
    // bloquear el pasillo cuando ya va de camino: debe recalcular
    out['laberinto pared nueva'] = run('pig', {}, S, G, 1600, e => { for (let y = 0; y < 3; y++) setBlock(X + 10, Y + y, Z + 7, B.brick); });
    for (let y = 0; y < 3; y++) setBlock(X + 10, Y + y, Z + 7, 0);
    // escalones de subida
    for (let i = 1; i <= 4; i++) for (let y = 0; y < i; y++) for (let z = 0; z < 3; z++) setBlock(X + 20 + i, Y + y, Z + z, B.stone);
    for (let x = 18; x <= 27; x++) for (let z = -1; z <= 3; z++) setBlock(X + x, Y - 1, Z + z, B.stone);
    for (let z = 0; z < 3; z++) for (let y = 0; y < 4; y++) setBlock(X + 25, Y + y, Z + z, B.stone);
    for (const t of ['pig', 'sheep', 'slime']) out['escalera ' + t] = run(t, t === 'slime' ? { size: 0.9 } : {}, [X + 19, Y, Z + 1], [X + 25, Y + 4, Z + 1], 600);
    // IA completa durante 90 s simulados con 25 criaturas
    window.think = realThink; window.thinkSlime = realThinkSlime;
    let stuck = 0, giveUps = 0; const origStuck = onStuck;
    window.onStuck = (e) => { stuck++; origStuck(e); if (!e.path) giveUps++; };
    for (let i = 0; i < 25; i++) { const a = i / 25 * 6.28, x = P.x + Math.cos(a) * 12, z = P.z + Math.sin(a) * 12, y = surfaceY(x, z); if (y !== null) new Mob(['pig', 'sheep', 'chicken', 'slime'][i % 4], x, y + 1, z, { wild: true }); }
    const n0 = entities.length;
    let moved = 0, pathsMade = 0;
    for (let s = 0; s < 1800; s++) { pathBudget = 2500; updateEntities(0.05); }
    out.vivo = { criaturas: n0, siguen: entities.length, atascos: stuck, seRinden: giveUps, enPared: entities.filter(e => !e.def.fly && boxHits(e.pos.x, e.pos.y, e.pos.z, e.hw, e.h)).length };
    return out;
  });
  for (const [k, v] of Object.entries(r)) console.log(k.padEnd(26), JSON.stringify(v));
  console.log('errores', JSON.stringify(errs));
  await b.close();
})();
