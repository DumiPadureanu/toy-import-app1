# HANA Database Setup Guide

## Prerequisites

- SAP HANA Cloud instance or on-premise HANA
- SAP Database Explorer access
- Cloud Foundry CLI (for BTP deployments)

## Option 1: HANA Cloud (Recommended)

### Step 1: Create HANA Cloud Instance

1. Log in to SAP BTP Cockpit
2. Navigate to your subaccount
3. Go to "SAP HANA Cloud" → "Create Instance"
4. Select "SAP HANA Cloud, SAP HANA Database"
5. Configure:
   - Instance Name: `toy-import-app-db`
   - Memory: 30 GB (minimum for dev)
   - Storage: 120 GB
   - Compute: 2 vCPUs

### Step 2: Get Connection Details

1. Open SAP HANA Cloud Central
2. Select your instance
3. Copy connection details:
   - Host: `<instance-id>.hanacloud.ondemand.com`
   - Port: `443` (SSL)
   - SQL Endpoint: Use for JDBC/ODBC connections

### Step 3: Configure HDI Container

Create an HDI container for the application:

```bash
cf create-service hana hdi-shared toy-import-app-db
```

### Step 4: Update .env File

```env
HANA_HOST=<instance-id>.hanacloud.ondemand.com
HANA_PORT=443
HANA_USER=<your-user>
HANA_PASSWORD=<your-password>
HANA_SCHEMA=<schema-name>
```

## Option 2: On-Premise HANA

### Step 1: Access HANA System

1. Connect via SAP HANA Studio or Database Explorer
2. Verify system access and permissions

### Step 2: Create Schema

```sql
CREATE SCHEMA TOY_IMPORT_APP;
```

### Step 3: Grant Permissions

```sql
GRANT CREATE ANY, SELECT, INSERT, UPDATE, DELETE ON SCHEMA TOY_IMPORT_APP TO <your-user>;
```

### Step 4: Update .env File

```env
HANA_HOST=<hana-server-host>
HANA_PORT=30015
HANA_USER=<your-user>
HANA_PASSWORD=<your-password>
HANA_SCHEMA=TOY_IMPORT_APP
```

## Deploy Database Schema

### Using CAP CLI

```bash
# Deploy to HANA
cds deploy --to hana

# Or with profile
cds deploy --to hana --profile production
```

### Manual Deployment

```bash
# Build HDI artifacts
cds build --production

# Deploy via Cloud Foundry
cf push toy-import-app-db-deployer -p gen/db
```

## Verify Database Setup

### Check Deployment

```bash
# List deployed tables
cds run --in-memory=false
curl http://localhost:4004/$metadata
```

### Query in Database Explorer

1. Open SAP Database Explorer
2. Connect to your HANA instance
3. Run test query:

```sql
SELECT * FROM COM_TOYPLATFORM_INVENTORY_PRODUCTS;
SELECT * FROM COM_TOYPLATFORM_IMPORTS_SUPPLIERS;
```

## Troubleshooting

### Connection Refused
- Verify firewall rules allow connection to HANA port
- Check if HANA instance is running
- Confirm SSL/TLS settings

### Authentication Failed
- Verify credentials in .env
- Check user permissions in HANA
- Ensure schema exists

### HDI Deployment Fails
- Check Cloud Foundry service bindings
- Verify HDI container is running
- Review deployer logs: `cf logs toy-import-app-db-deployer --recent`

## Production Recommendations

1. **Use HDI Containers**: Isolate application database artifacts
2. **Enable SSL**: Always use encrypted connections
3. **Backup Strategy**: Configure automatic backups in HANA Cloud
4. **Monitoring**: Enable SAP HANA Cloud monitoring
5. **Scaling**: Start with 30GB, scale based on data growth

## Resources

- [SAP HANA Cloud Documentation](https://help.sap.com/docs/HANA_CLOUD)
- [CAP Database Guide](https://cap.cloud.sap/docs/guides/databases)
- [HDI Container Reference](https://help.sap.com/docs/HANA_CLOUD_DATABASE/c2b99f19e9264c4d9ae9221b22f6f589/e28abca91a004683845805efc2bf967c.html)
