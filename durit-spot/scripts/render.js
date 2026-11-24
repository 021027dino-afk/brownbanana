// Renders spot.html frame by frame and pipes JPEG frames into ffmpeg.
// usage: node scripts/render.js out.mp4 audio.wav [fps]
const { chromium } = require('playwright');
const { spawn } = require('child_process');
const path = require('path');

(async () => {
  const [, , out, audio, fpsArg] = process.argv;
  const fps = parseInt(fpsArg || '30', 10);
  const frames = Math.round(30 * fps);
  const ff = spawn('ffmpeg', ['-y', '-loglevel', 'error',
    '-f', 'image2pipe', '-framerate', String(fps), '-c:v', 'mjpeg', '-i', '-',
    '-i', audio,
    '-c:v', 'libx264', '-preset', 'slow', '-crf', '17', '-pix_fmt', 'yuv420p',
    '-c:a', 'aac', '-b:a', '256k', '-shortest', '-movflags', '+faststart', out], { stdio: ['pipe', 'inherit', 'inherit'] });

  const browser = await chromium.launch({ args: ['--allow-file-access-from-files'] });
  const page = await browser.newPage({ viewport: { width: 1080, height: 1920 } });
  page.on('pageerror', e => console.error('page error:', e.message));
  await page.goto('file://' + path.resolve(__dirname, '../' + (process.env.PAGE || 'spot.html')));
  await page.evaluate(() => window.ready);
  for (let i = 0; i < frames; i++) {
    const b64 = await page.evaluate(async t => { if (window.prepare) await window.prepare(t); window.render(t); return document.getElementById('c').toDataURL('image/jpeg', 0.95).split(',')[1]; }, i / fps);
    if (!ff.stdin.write(Buffer.from(b64, 'base64'))) await new Promise(r => ff.stdin.once('drain', r));
    if (i % 90 === 0) console.log(`frame ${i}/${frames}`);
  }
  ff.stdin.end();
  await new Promise(r => ff.on('close', r));
  await browser.close();
  console.log('done', out);
})();
