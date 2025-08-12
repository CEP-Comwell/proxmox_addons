import { EnrollDevice } from '../../../src/application/use-cases/device-enrollment/EnrollDevice';
import { IntegrationPort } from '../../../src/application/ports/IntegrationPort';

describe('EnrollDevice', () => {
  it('should enroll device using mock adapter', async () => {
    const mockPort: IntegrationPort = {
      enrollDevice: jest.fn().mockResolvedValue(true)
    };
    const enrollDevice = new EnrollDevice(mockPort);
    const result = await enrollDevice.execute('device123');
    expect(result).toBe(true);
    expect(mockPort.enrollDevice).toHaveBeenCalledWith('device123', undefined);
  });
});
