const { chromium } = require('playwright');
const path = require('path');
(async () => {
  const [,, outDir, ...times] = process.argv;
  const b = await chromium.launch({args:['--allow-file-access-from-files']});
  const p = await b.newPage({ viewport: { width: 1080, height: 1920 } });
  p.on('console', m => console.log('console:', m.text()));
  p.on('pageerror', e => console.log('ERR:', e.message));
  await p.goto('file://' + path.resolve(__dirname, '../spot.html'));
  await p.evaluate(() => window.ready);
  for (const t of times) {
    await p.evaluate(t => window.render(t), parseFloat(t));
    await p.screenshot({ path: `${outDir}/t${t}.png` });
  }
  await b.close();
})();
