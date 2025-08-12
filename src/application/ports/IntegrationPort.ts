export interface IntegrationPort {
  enrollDevice(deviceId: string, metadata?: any): Promise<boolean>;
}
