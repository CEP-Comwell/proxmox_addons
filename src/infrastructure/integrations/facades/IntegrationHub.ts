import { IntegrationPort } from '../../../application/ports/IntegrationPort';
import { DeviceAdapter } from '../adapters/DeviceAdapter';

export class IntegrationHub implements IntegrationPort {
  private adapter: DeviceAdapter;

  constructor() {
    this.adapter = new DeviceAdapter();
  }

  async enrollDevice(deviceId: string, metadata?: any): Promise<boolean> {
    // Delegate to adapter
    return await this.adapter.enrollDevice(deviceId, metadata);
  }
}
