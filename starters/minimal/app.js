const http = require('http');

const PORT = parseInt(process.env.PORT || '3000', 10);
const DOMAIN = process.env.DOMAIN || 'localhost';
const APP_NAME = process.env.APP_NAME || 'Node.js Minimal';

const server = http.createServer((req, res) => {
  if (req.url === '/health' || req.url === '/api/status') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    return res.end(JSON.stringify({
      app: APP_NAME,
      domain: DOMAIN,
      port: PORT,
      status: 'online',
      node: process.version,
      uptime: process.uptime()
    }));
  }

  res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
  res.end(`<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>${APP_NAME} | HestiaCP</title>
  <style>
    body { font-family: system-ui, sans-serif; background: #0f172a; color: #f8fafc; display: flex; align-items: center; justify-content: center; min-height: 100vh; margin: 0; }
    .card { background: #1e293b; padding: 2rem; border-radius: 0.75rem; text-align: center; max-width: 500px; border: 1px solid #334155; }
    h1 { color: #38bdf8; margin-top: 0; }
    .meta { font-family: monospace; background: #0f172a; padding: 1rem; border-radius: 0.5rem; margin: 1rem 0; text-align: left; }
    a { color: #38bdf8; }
  </style>
</head>
<body>
  <div class="card">
    <h1>🚀 Servidor Nativo Node.js</h1>
    <p>Zero dependencias externas, corriendo vía HTTP nativo con PM2.</p>
    <div class="meta">
      <div>App: ${APP_NAME}</div>
      <div>Puerto: ${PORT}</div>
      <div>Ubicación: ~/web/${DOMAIN}/public_html</div>
    </div>
    <a href="/api/status">/api/status</a>
  </div>
</body>
</html>`);
});

server.listen(PORT, '127.0.0.1', () => {
  console.log(`[Minimal] Servidor escuchando en http://127.0.0.1:${PORT}`);
});
