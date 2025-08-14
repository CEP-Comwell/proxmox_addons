import test from 'node:test';
import assert from 'node:assert';
import Fastify from 'fastify';
import pino from 'pino';

test('GET /healthz', async () => {
  const app = Fastify({ loggerInstance: pino({enabled:false}) });
  await app.register(import('@fastify/sensible'));
  await app.get('/healthz', { schema: { response: {200: { type:'object', properties:{ok:{type:'boolean'}}, required:['ok'] } } } }, async () => ({ ok: true }));
  const res = await app.inject({ method: 'GET', url: '/healthz' });
  assert.equal(res.statusCode, 200);
  assert.deepEqual(res.json(), { ok: true });
});
