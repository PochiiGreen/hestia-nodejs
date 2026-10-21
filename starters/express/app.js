require('dotenv').config();
const express = require('express');
const path = require('path');

const app = express();
const PORT = parseInt(process.env.PORT || '3000', 10);
const DOMAIN = process.env.DOMAIN || 'localhost';
const APP_NAME = process.env.APP_NAME || 'Express App';

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

if (path.resolve(__dirname, 'public')) {
  app.use(express.static(path.join(__dirname, 'public')));
}

app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    uptime: process.uptime(),
    timestamp: new Date().toISOString()
  });
});

app.get('/api/status', (req, res) => {
  res.json({
    app: APP_NAME,
    domain: DOMAIN,
    port: PORT,
    node: process.version,
    env: process.env.NODE_ENV || 'production',
    status: 'online'
  });
});

app.get('/', (req, res) => {
  res.send(`<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${APP_NAME} | HestiaCP</title>
  <style>
    body { font-family: system-ui, -apple-system, sans-serif; background: #0f172a; color: #f8fafc; display: flex; align-items: center; justify-content: center; min-height: 100vh; margin: 0; }
    .card { background: #1e293b; padding: 2.5rem; border-radius: 1rem; box-shadow: 0 10px 25px rgba(0,0,0,0.5); max-width: 550px; width: 90%; text-align: center; border: 1px solid #334155; }
    h1 { color: #38bdf8; margin-top: 0; font-size: 1.8rem; }
    .badge { background: #0284c7; color: #fff; padding: 0.25rem 0.75rem; border-radius: 9999px; font-size: 0.85rem; font-weight: 600; }
    .meta { margin: 1.5rem 0; text-align: left; background: #0f172a; padding: 1rem; border-radius: 0.5rem; font-family: monospace; font-size: 0.9rem; line-height: 1.6; }
    .meta span { color: #a5f3fc; }
    a { color: #38bdf8; text-decoration: none; }
    a:hover { text-decoration: underline; }
  </style>
</head>
<body>
  <div class="card">
    <span class="badge">Node.js + PM2 en HestiaCP</span>
    <h1>🚀 ${APP_NAME}</h1>
    <p>Tu aplicación Express está corriendo exitosamente en HestiaCP.</p>
    <div class="meta">
      <div>Dominio: <span>${DOMAIN}</span></div>
      <div>Puerto Interno: <span>${PORT}</span></div>
      <div>Node Version: <span>${process.version}</span></div>
      <div>Ubicación: <span>~/web/${DOMAIN}/private/nodeapp</span></div>
    </div>
    <p><a href="/api/status">Endpoint /api/status</a> · <a href="/health">Health Check</a></p>
  </div>
</body>
</html>`);
});

app.listen(PORT, '127.0.0.1', () => {
  console.log(`[Express] Servidor escuchando en http://127.0.0.1:${PORT}`);
});
