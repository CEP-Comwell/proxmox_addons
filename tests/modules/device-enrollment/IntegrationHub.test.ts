import { IntegrationHub } from '../../../src/infrastructure/integrations/facades/IntegrationHub';

describe('IntegrationHub', () => {
  it('should delegate enrollDevice to DeviceAdapter', async () => {
    const hub = new IntegrationHub();
    const result = await hub.enrollDevice('device456');
    expect(result).toBe(true);
  });
});
