import { IntegrationHub } from '../infrastructure/integrations/facades/IntegrationHub';
import { EnrollDevice } from '../application/use-cases/device-enrollment/EnrollDevice';

const deviceId = process.argv[2];
if (!deviceId) {
  console.error('Usage: npm run enroll <deviceId>');
  process.exit(1);
}

const integrationHub = new IntegrationHub();
const enrollDevice = new EnrollDevice(integrationHub);

enrollDevice.execute(deviceId, { source: 'CLI' })
  .then(result => {
    if (result) {
      console.log(`Device ${deviceId} enrolled successfully.`);
    } else {
      console.error(`Failed to enroll device ${deviceId}.`);
    }
  })
  .catch(err => {
    console.error('Error during enrollment:', err);
  });
