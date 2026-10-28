(function (global) {
  'use strict';

  function launch() {
    if (global.matchMedia && global.matchMedia('(prefers-reduced-motion: reduce)').matches) return;
    if (!document.body) return;

    var canvas = document.createElement('canvas');
    canvas.className = 'codearena-confetti-canvas';
    canvas.setAttribute('aria-hidden', 'true');
    Object.assign(canvas.style, {
      position: 'fixed', inset: '0', width: '100vw', height: '100vh',
      pointerEvents: 'none', zIndex: '99999'
    });
    document.body.appendChild(canvas);

    var ctx = canvas.getContext('2d');
    if (!ctx) { canvas.remove(); return; }
    var width = canvas.width = Math.max(1, global.innerWidth * (global.devicePixelRatio || 1));
    var height = canvas.height = Math.max(1, global.innerHeight * (global.devicePixelRatio || 1));
    var scale = global.devicePixelRatio || 1;
    ctx.scale(scale, scale);
    width = global.innerWidth;
    height = global.innerHeight;

    var colors = ['#16a34a', '#22c55e', '#f59e0b', '#6356df', '#ec4899', '#0ea5e9', '#84cc16'];
    var particles = [];
    var count = Math.min(160, Math.max(90, Math.floor(width / 7)));
    for (var i = 0; i < count; i++) {
      particles.push({
        x: Math.random() * width,
        y: -20 - Math.random() * height * 0.5,
        vx: (Math.random() - 0.5) * 3.5,
        vy: 2 + Math.random() * 4.5,
        size: 4 + Math.random() * 5,
        rotation: Math.random() * Math.PI * 2,
        spin: (Math.random() - 0.5) * 0.18,
        color: colors[Math.floor(Math.random() * colors.length)],
        shape: Math.random() > 0.35 ? 'rect' : 'circle',
        wobble: Math.random() * Math.PI * 2
      });
    }

    var startTime = null;
    var duration = 3600;
    function frame(timestamp) {
      if (startTime === null) startTime = timestamp;
      var elapsed = timestamp - startTime;
      ctx.clearRect(0, 0, width, height);
      var opacity = elapsed < duration - 650 ? 1 : Math.max(0, (duration - elapsed) / 650);
      particles.forEach(function (p) {
        p.x += p.vx + Math.sin(p.wobble + elapsed / 160) * 0.8;
        p.y += p.vy;
        p.rotation += p.spin;
        p.wobble += 0.025;
        if (p.y > height + 25) { p.y = -15; p.x = Math.random() * width; }
        ctx.save();
        ctx.globalAlpha = opacity;
        ctx.translate(p.x, p.y);
        ctx.rotate(p.rotation);
        ctx.fillStyle = p.color;
        if (p.shape === 'rect') ctx.fillRect(-p.size / 2, -p.size / 3, p.size, p.size * 0.65);
        else { ctx.beginPath(); ctx.arc(0, 0, p.size / 2, 0, Math.PI * 2); ctx.fill(); }
        ctx.restore();
      });
      if (elapsed < duration) global.requestAnimationFrame(frame);
      else canvas.remove();
    }
    global.requestAnimationFrame(frame);
  }

  function launchOnce(key) {
    var alreadyShown = false;
    try {
      alreadyShown = global.sessionStorage.getItem(key) === '1';
      if (!alreadyShown) global.sessionStorage.setItem(key, '1');
    } catch (_) { /* Session storage may be disabled; show the effect anyway. */ }
    if (!alreadyShown) launch();
  }

  global.CodeArenaConfetti = { launchOnce: launchOnce };
})(window);
