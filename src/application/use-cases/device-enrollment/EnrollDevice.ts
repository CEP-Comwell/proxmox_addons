import { IntegrationPort } from '../../ports/IntegrationPort';

export class EnrollDevice {
  constructor(private integrationPort: IntegrationPort) {}

  async execute(deviceId: string, metadata?: any): Promise<boolean> {
    // Core business logic for device enrollment
    return await this.integrationPort.enrollDevice(deviceId, metadata);
  }
}
