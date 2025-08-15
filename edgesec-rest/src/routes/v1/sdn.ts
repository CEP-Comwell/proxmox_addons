import { FastifyInstance } from 'fastify';
import { recommendSubnet } from '../../lib/sdn.js';
import { sdnRecommendSubnetSchema } from '../../schemas/sdnRecommendSubnet.schema.js';

export default async function sdnRoutes(fastify: FastifyInstance) {
  // TODO: Add authentication middleware (integrate with edgesec-VAULT)
  fastify.post('/api/v1/sdn/recommend/subnet', {
    schema: sdnRecommendSubnetSchema,
    handler: async (request, reply) => {
      // @ts-ignore
      const { site, tenant_id, purpose, device_id, metadata } = request.body;
      const result = await recommendSubnet({ site, tenant_id, purpose, device_id, metadata });
      reply.send(result);
    }
  });
}
