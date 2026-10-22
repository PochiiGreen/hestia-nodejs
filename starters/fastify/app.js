require('dotenv').config();
const fastify = require('fastify')({ logger: true });

const PORT = parseInt(process.env.PORT || '3000', 10);
const DOMAIN = process.env.DOMAIN || 'localhost';
const APP_NAME = process.env.APP_NAME || 'Fastify App';

fastify.get('/health', async () => ({
  status: 'healthy',
  uptime: process.uptime(),
  timestamp: new Date().toISOString()
}));

fastify.get('/api/status', async () => ({
  app: APP_NAME,
  domain: DOMAIN,
  port: PORT,
  node: process.version,
  framework: 'Fastify',
  status: 'online'
}));

fastify.get('/', async (request, reply) => {
  reply.type('text/html').send(`<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>${APP_NAME} | HestiaCP</title>
  <style>
    body { font-family: system-ui, sans-serif; background: #111827; color: #f9fafb; display: flex; align-items: center; justify-content: center; min-height: 100vh; margin: 0; }
    .card { background: #1f2937; padding: 2.5rem; border-radius: 1rem; max-width: 520px; width: 90%; text-align: center; border: 1px solid #374151; }
    h1 { color: #10b981; }
    .meta { text-align: left; background: #111827; padding: 1rem; border-radius: 0.5rem; font-family: monospace; margin: 1.5rem 0; }
    a { color: #10b981; }
  </style>
</head>
<body>
  <div class="card">
    <h1>⚡ Fastify Activo en HestiaCP</h1>
    <p>Servidor de alto rendimiento corriendo en segundo plano.</p>
    <div class="meta">
      <div>Dominio: ${DOMAIN}</div>
      <div>Puerto: ${PORT}</div>
      <div>Ubicación: ~/web/${DOMAIN}/public_html</div>
    </div>
    <a href="/api/status">Ver /api/status</a>
  </div>
</body>
</html>`);
});

const start = async () => {
  try {
    await fastify.listen({ port: PORT, host: '127.0.0.1' });
    console.log(`[Fastify] Escuchando en http://127.0.0.1:${PORT}`);
  } catch (err) {
    fastify.log.error(err);
    process.exit(1);
  }
};
start();
