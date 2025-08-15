export const sdnRecommendSubnetSchema = {
  body: {
    type: 'object',
    required: ['site', 'tenant_id', 'purpose', 'device_id'],
    properties: {
      site: { type: 'string' },
      tenant_id: { type: 'string' },
      purpose: { type: 'string' },
      device_id: { type: 'string' },
      metadata: { type: 'object', additionalProperties: true }
    }
  },
  response: {
    200: {
      type: 'object',
      properties: {
        subnet: { type: 'string' },
        site: { type: 'string' },
        tenant_id: { type: 'string' },
        purpose: { type: 'string' },
        device_id: { type: 'string' },
        metadata: { type: 'object', additionalProperties: true },
        reason: { type: 'string' },
        available_ips: { type: 'number' }
      }
    }
  }
};
