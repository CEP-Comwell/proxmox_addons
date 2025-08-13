// src/config.ts
export const VAULT_ADDR = process.env.VAULT_ADDR || 'http://localhost:8200';
export const VAULT_TOKEN = process.env.VAULT_TOKEN || '';
export const AUTHENTIK_URL = process.env.AUTHENTIK_URL || 'http://localhost:9000';
export const SMALLSTEP_CA_URL = process.env.SMALLSTEP_CA_URL || 'http://localhost:8080';
export const FREERADIUS_SERVER = process.env.FREERADIUS_SERVER || 'localhost';
export const NETBOX_URL = process.env.NETBOX_URL || 'http://localhost:8000';
export const CERT_TENANT = process.env.CERT_TENANT || 'example_tenant';
