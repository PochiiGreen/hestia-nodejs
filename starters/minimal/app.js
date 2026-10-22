const http = require('http');

const PORT = parseInt(process.env.PORT || '3000', 10);
const DOMAIN = process.env.DOMAIN || 'localhost';
const APP_NAME = process.env.APP_NAME || 'Node.js Minimal';

const server = http.createServer((req, res) => {
  if (req.url === '/health') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    return res.end(JSON.stringify({ status: 'healthy', uptime: process.uptime(), timestamp: new Date().toISOString() }));
  }

  if (req.url === '/api/status') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    return res.end(JSON.stringify({
      app: APP_NAME,
      domain: DOMAIN,
      port: PORT,
      status: 'online',
      node: process.version,
      author: 'pochii-dev',
      version: '1.0 (APA)'
    }));
  }

  res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
  res.end(`<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${APP_NAME} | HestiaCP Node.js</title>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
  <style>
    :root {
      --bg: #090d16;
      --card-bg: rgba(17, 24, 39, 0.75);
      --card-border: rgba(255, 255, 255, 0.08);
      --primary: #a855f7;
      --mp-blue: #009ee3;
      --text: #f1f5f9;
      --text-muted: #94a3b8;
    }
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body {
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
      background: var(--bg);
      background-image: 
        radial-gradient(at 0% 0%, rgba(168, 85, 247, 0.12) 0px, transparent 50%),
        radial-gradient(at 100% 100%, rgba(56, 189, 248, 0.1) 0px, transparent 50%);
      color: var(--text);
      min-height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
      padding: 1.5rem;
    }
    .container { max-width: 680px; width: 100%; }
    .card {
      background: var(--card-bg);
      backdrop-filter: blur(20px);
      -webkit-backdrop-filter: blur(20px);
      border: 1px solid var(--card-border);
      border-radius: 1.25rem;
      padding: 2.25rem;
      box-shadow: 0 20px 50px rgba(0, 0, 0, 0.6);
      position: relative;
      overflow: hidden;
    }
    .card::before {
      content: "";
      position: absolute;
      top: 0; left: 0; right: 0; height: 3px;
      background: linear-gradient(90deg, #a855f7, #38bdf8, #10b981);
    }
    .status-badge {
      display: inline-flex;
      align-items: center;
      gap: 0.5rem;
      background: rgba(168, 85, 247, 0.12);
      border: 1px solid rgba(168, 85, 247, 0.3);
      color: #c084fc;
      padding: 0.35rem 0.85rem;
      border-radius: 9999px;
      font-size: 0.8rem;
      font-weight: 600;
    }
    .pulse-dot {
      width: 8px; height: 8px; background: #a855f7; border-radius: 50%;
      box-shadow: 0 0 10px #a855f7; animation: pulse 2s infinite;
    }
    @keyframes pulse { 0%, 100% { opacity: 1; transform: scale(1); } 50% { opacity: 0.4; transform: scale(0.85); } }
    .header { margin-top: 1rem; margin-bottom: 1.5rem; }
    .header h1 {
      font-size: 1.9rem; font-weight: 800;
      background: linear-gradient(135deg, #f8fafc 20%, #94a3b8 100%);
      -webkit-background-clip: text; -webkit-text-fill-color: transparent;
      margin-bottom: 0.4rem;
    }
    .header p { color: var(--text-muted); font-size: 0.95rem; line-height: 1.5; }
    .grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: 0.75rem; margin-bottom: 1.5rem; }
    @media (max-width: 580px) { .grid { grid-template-columns: 1fr; } }
    .info-box {
      background: rgba(15, 23, 42, 0.6);
      border: 1px solid rgba(255, 255, 255, 0.05);
      padding: 0.85rem 1rem;
      border-radius: 0.75rem;
      display: flex; flex-direction: column; gap: 0.25rem;
    }
    .info-label {
      font-size: 0.75rem; text-transform: uppercase; letter-spacing: 0.05em;
      color: var(--text-muted); display: flex; align-items: center; gap: 0.4rem;
    }
    .info-label i { font-size: 0.85rem; color: var(--primary); }
    .info-value {
      font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace;
      font-size: 0.88rem; color: #e2e8f0; font-weight: 600; word-break: break-all;
    }
    .highlight-green { color: #34d399 !important; }
    .highlight-blue { color: #38bdf8 !important; }

    .mp-box {
      background: linear-gradient(135deg, rgba(0, 158, 227, 0.08) 0%, rgba(15, 23, 42, 0.8) 100%);
      border: 1px solid rgba(0, 158, 227, 0.3);
      border-radius: 0.9rem; padding: 1.15rem; margin-bottom: 1.5rem;
      display: flex; align-items: center; justify-content: space-between; gap: 1rem; flex-wrap: wrap;
    }
    .mp-info { display: flex; align-items: center; gap: 0.85rem; }
    .mp-icon {
      width: 44px; height: 44px; background: var(--mp-blue); border-radius: 0.75rem;
      display: flex; align-items: center; justify-content: center; color: #fff;
      font-size: 1.25rem; box-shadow: 0 4px 14px rgba(0, 158, 227, 0.4); flex-shrink: 0;
    }
    .mp-title { font-size: 0.85rem; font-weight: 700; color: #e0f2fe; }
    .mp-sub { font-size: 0.78rem; color: #7dd3fc; }
    .alias-badge {
      background: rgba(0, 158, 227, 0.15); border: 1px dashed rgba(0, 158, 227, 0.5);
      padding: 0.4rem 0.85rem; border-radius: 0.5rem; font-family: monospace;
      font-size: 0.88rem; color: #38bdf8; font-weight: 700; display: inline-flex;
      align-items: center; gap: 0.5rem; cursor: pointer; transition: all 0.2s ease;
    }
    .alias-badge:hover {
      background: rgba(0, 158, 227, 0.25); border-color: #38bdf8; transform: translateY(-1px);
    }
    .actions { display: flex; gap: 0.75rem; flex-wrap: wrap; }
    .btn {
      display: inline-flex; align-items: center; gap: 0.5rem; padding: 0.55rem 1rem;
      border-radius: 0.6rem; font-size: 0.82rem; font-weight: 600; text-decoration: none;
      transition: all 0.2s ease; cursor: pointer;
    }
    .btn-primary { background: rgba(168, 85, 247, 0.1); border: 1px solid rgba(168, 85, 247, 0.3); color: #c084fc; }
    .btn-primary:hover { background: rgba(168, 85, 247, 0.2); border-color: #c084fc; color: #fff; }
    .btn-outline { background: rgba(255, 255, 255, 0.03); border: 1px solid rgba(255, 255, 255, 0.1); color: var(--text-muted); }
    .btn-outline:hover { background: rgba(255, 255, 255, 0.08); color: var(--text); }

    .footer {
      margin-top: 1.5rem; padding-top: 1.25rem; border-top: 1px solid rgba(255, 255, 255, 0.06);
      display: flex; justify-content: space-between; align-items: center;
      font-size: 0.78rem; color: var(--text-muted); flex-wrap: wrap; gap: 0.75rem;
    }
    .footer a { color: #cbd5e1; text-decoration: none; font-weight: 600; }
    .footer a:hover { color: var(--primary); }
    .author-badge { display: inline-flex; align-items: center; gap: 0.4rem; color: #e2e8f0; font-weight: 600; }
  </style>
</head>
<body>
  <div class="container">
    <div class="card">
      <div style="display: flex; justify-content: space-between; align-items: center;">
        <div class="status-badge">
          <div class="pulse-dot"></div>
          <span>Online • Node.js Nativo en HestiaCP</span>
        </div>
        <span style="font-size: 0.75rem; font-family: monospace; color: #64748b;">v1.0 (APA)</span>
      </div>

      <div class="header">
        <h1>🚀 ${APP_NAME}</h1>
        <p>Servidor HTTP nativo de Node.js corriendo con zero dependencias externas bajo PM2 y Nginx.</p>
      </div>

      <div class="grid">
        <div class="info-box">
          <span class="info-label"><i class="fa-solid fa-globe"></i> Dominio Web</span>
          <span class="info-value highlight-blue">${DOMAIN}</span>
        </div>
        <div class="info-box">
          <span class="info-label"><i class="fa-solid fa-network-wired"></i> Puerto Interno</span>
          <span class="info-value highlight-green">:${PORT}</span>
        </div>
        <div class="info-box">
          <span class="info-label"><i class="fa-brands fa-node-js"></i> Node.js Version</span>
          <span class="info-value">${process.version}</span>
        </div>
        <div class="info-box">
          <span class="info-label"><i class="fa-solid fa-microchip"></i> Gestor PM2</span>
          <span class="info-value">Daemon (Single Fork)</span>
        </div>
        <div class="info-box" style="grid-column: span 2;">
          <span class="info-label"><i class="fa-solid fa-folder-open"></i> Directorio del Proyecto</span>
          <span class="info-value highlight-green">~/web/${DOMAIN}/public_html</span>
        </div>
      </div>

      <!-- Mercado Pago Support Box -->
      <div class="mp-box">
        <div class="mp-info">
          <div class="mp-icon">
            <i class="fa-solid fa-hand-holding-dollar"></i>
          </div>
          <div>
            <div class="mp-title">Apoyar este Proyecto Libre</div>
            <div class="mp-sub">Donaciones voluntarias vía Mercado Pago</div>
          </div>
        </div>
        <div>
          <button class="alias-badge" id="copyAliasBtn" onclick="copyAlias()">
            <i class="fa-solid fa-copy"></i>
            <span id="aliasText">potschka.roberto</span>
          </button>
        </div>
      </div>

      <!-- Endpoints & Actions -->
      <div class="actions">
        <a href="/api/status" class="btn btn-primary" target="_blank">
          <i class="fa-solid fa-code"></i> API Status (/api/status)
        </a>
        <a href="/health" class="btn btn-outline" target="_blank">
          <i class="fa-solid fa-heart-pulse"></i> Health Check (/health)
        </a>
        <a href="https://github.com/PochiiGreen/hestia-nodejs" class="btn btn-outline" target="_blank" rel="noopener">
          <i class="fa-brands fa-github"></i> Repositorio GitHub
        </a>
      </div>

      <div class="footer">
        <div class="author-badge">
          <i class="fa-solid fa-shield-halved" style="color: #a855f7;"></i>
          Creado por <a href="https://github.com/PochiiGreen" target="_blank">pochii-dev</a> · v1.0 (APA)
        </div>
        <div>Hestia Control Panel v1.10.x & v1.10.5+</div>
      </div>
    </div>
  </div>

  <script>
    function copyAlias() {
      const alias = 'potschka.roberto';
      navigator.clipboard.writeText(alias).then(() => {
        const btn = document.getElementById('copyAliasBtn');
        const text = document.getElementById('aliasText');
        text.innerText = '¡Alias Copiado!';
        btn.style.borderColor = '#10b981';
        btn.style.color = '#34d399';
        setTimeout(() => {
          text.innerText = alias;
          btn.style.borderColor = '';
          btn.style.color = '';
        }, 2500);
      }).catch(err => {
        alert('Alias Mercado Pago: ' + alias);
      });
    }
  </script>
</body>
</html>`);
});

server.listen(PORT, '127.0.0.1', () => {
  console.log(`[Minimal] Servidor escuchando en http://127.0.0.1:${PORT}`);
});
