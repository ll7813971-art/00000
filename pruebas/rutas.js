// mide el pathfinding: criaturas con un objetivo, simulación rápida
const { chromium } = require('playwright');
(async () => {
  const b = await chromium.launch({args:['--use-gl=angle','--use-angle=swiftshader','--enable-unsafe-swiftshader']});
  const out = {};
  for (const seed of [42, 7, 1234]) {
    const p = await b.newPage({viewport:{width:400,height:300}});
    const errs=[]; p.on('pageerror',e=>errs.push(e.message));
    await p.goto('file://' + require('path').resolve(__dirname, '../index.html') + '?semilla='+seed);
    await p.waitForFunction(()=>document.getElementById('status').textContent.startsWith('Mundo listo'),null,{timeout:60000});
    await p.waitForTimeout(4000);
    const r = await p.evaluate(() => {
      window.think = () => {}; window.thinkSlime = () => {};
      for (const e of entities) if (e.wild) e.remove();
      const res = {};
      let R = 12345; const rnd = () => (R = (R * 16807) % 2147483647) / 2147483647;
      const surf = (x, z, hc) => { const y = surfaceY(x, z); if (y === null) return null; if (getBlock(x, y, z) === B.water) return null; if (!standable(Math.floor(x), y + 1, Math.floor(z), hc)) return null; return y + 1; };
      for (const type of ['pig', 'sheep', 'chicken', 'slime']) {
        const st = { trials: 0, reached: 0, noPath: 0, partial: 0, stuck: 0, fell: 0, inWall: 0 };
        for (let t = 0; t < 30; t++) {
          const a = rnd() * 6.28, d = rnd() * 20, sx = player.pos.x + Math.cos(a) * d, sz = player.pos.z + Math.sin(a) * d;
          const hc = type === 'sheep' ? 2 : 1;
          const sy = surf(sx, sz, hc); if (sy === null) { t--; continue; }
          const a2 = rnd() * 6.28, d2 = 6 + rnd() * 8, gx = Math.floor(sx + Math.cos(a2) * d2) + 0.5, gz = Math.floor(sz + Math.sin(a2) * d2) + 0.5;
          const gy = surf(gx, gz, hc); if (gy === null) { t--; continue; }
          const e = new Mob(type, Math.floor(sx) + 0.5, sy, Math.floor(sz) + 0.5, type === 'slime' ? { size: 0.9 } : {});
          st.trials++;
          const goal = new THREE.Vector3(gx, gy, gz);
          pathBudget = 99999;
          const ok = goTo(e, goal, 0.5);
          if (!ok) { st.noPath++; e.remove(); continue; }
          const last = e.path[e.path.length - 1];
          const exact = Math.abs(last[0] + 0.5 - gx) < 1 && Math.abs(last[2] + 0.5 - gz) < 1 && last[1] === gy;
          if (!exact) st.partial++;
          let done = false;
          for (let s = 0; s < 400; s++) {
            pathBudget = 99999;
            e.age += 0.05; e.thinkT = 99;
            if (type === 'slime') updateSlime(e, 0.05); else updateGround(e, 0.05);
            if (Math.hypot(e.pos.x - gx, e.pos.z - gz) < 1.2 && Math.abs(e.pos.y - gy) < 1.5) { done = true; break; }
            if (!e.path && type !== 'slime') break;
          }
          if (boxHits(e.pos.x, e.pos.y, e.pos.z, e.hw, e.h)) st.inWall++;
          if (done) st.reached++; else if (exact) st.stuck++;
          e.remove();
        }
        res[type] = st;
      }
      return res;
    });
    out[seed] = r; if (errs.length) out[seed].errs = errs;
    await p.close();
  }
  console.log(JSON.stringify(out, null, 1));
  await b.close();
})();
