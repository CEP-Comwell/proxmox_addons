import Fastify from 'fastify';
import pino from 'pino';

const loggerInstance = pino({ level: process.env.LOG_LEVEL ?? 'info' });
const app = Fastify({ loggerInstance });

await app.register(import('@fastify/sensible'));
await app.register(import('@fastify/helmet'));
await app.register(import('@fastify/cors'), { origin: false });

// OPTIONAL: Temporarily host legacy Express app during migration.
// Uncomment when you need to mount it.
// import fastifyExpress from '@fastify/express';
// import legacyApp from '../legacy/app.js'; // adjust if exists
// await app.register(fastifyExpress);
// const { default: express } = await import('express');
// app.use(express.json());
// app.use(express.urlencoded({ extended: false }));
// app.use(legacyApp);

// Health route (with full JSON Schema as required by Fastify v5)
app.get('/healthz', {
  schema: {
    response: { 200: { type: 'object', properties: { ok: { type: 'boolean' } }, required: ['ok'] } }
  }
}, async () => ({ ok: true }));

const port = Number(process.env.PORT ?? 3001);
await app.listen({ port, host: '0.0.0.0' });
