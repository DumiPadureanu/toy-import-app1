# SAP BTP Deployment Guide

## Prerequisites

- SAP BTP Account (Trial or Enterprise)
- Cloud Foundry CLI installed
- MTA Build Tool installed: `npm install -g mbt`
- Valid HANA Cloud instance

## Step 1: Prepare for Deployment

### Build MTA Archive

```bash
# Build production artifacts
cds build --production

# Build MTA archive
mbt build -t gen --mtar toy-import-app.mtar
```

### Verify Build

```bash
ls -la gen/
# Should see toy-import-app.mtar
```

## Step 2: Configure Cloud Foundry

### Login to CF

```bash
cf login -a https://api.cf.eu10.hana.ondemand.com
# Enter credentials
```

### Target Your Space

```bash
cf target -o <your-org> -s <your-space>
```

### Verify Target

```bash
cf target
# Should show correct org and space
```

## Step 3: Create Required Services

### Create HANA HDI Container

```bash
cf create-service hana hdi-shared toy-import-app-db
```

### Create XSUAA Service

```bash
cf create-service xsuaa application toy-import-app-uaa -c xs-security.json
```

### Create Destination Service

```bash
cf create-service destination lite toy-import-app-destination
```

### Create HTML5 App Repository

```bash
cf create-service html5-apps-repo app-host toy-import-app-html5-host
cf create-service html5-apps-repo app-runtime toy-import-app-html5-runtime
```

### Verify Services

```bash
cf services
# All services should show "create succeeded"
```

## Step 4: Deploy Application

### Deploy MTA

```bash
cf deploy gen/toy-import-app.mtar --retries 1
```

### Monitor Deployment

```bash
# Watch deployment progress
cf apps

# Check logs if issues occur
cf logs toy-import-app-srv --recent
```

## Step 5: Verify Deployment

### Check Application Status

```bash
cf apps
# toy-import-app-srv should show "started"
```

### Get Application URL

```bash
cf app toy-import-app-srv
# Note the "routes" URL
```

### Test API

```bash
curl https://<your-app-route>/odata/v4/$metadata
# Should return OData metadata XML
```

## Step 6: Configure App Router

### Access Fiori Launchpad

```
https://<your-app-router-route>/index.html
```

### Configure Destinations

1. Open BTP Cockpit
2. Navigate to Connectivity → Destinations
3. Create destination for backend service:

```
Name: srv-api
Type: HTTP
URL: https://<srv-route>
Proxy Type: Internet
Authentication: NoAuthentication
```

## Step 7: Assign Roles

### Create Role Collections

1. Open BTP Cockpit → Security → Role Collections
2. Create role collections:
   - `ToyImportApp_Administrator`
   - `ToyImportApp_Manager`
   - `ToyImportApp_User`
   - `ToyImportApp_Viewer`

### Assign Roles to Users

1. Select role collection
2. Click "Edit"
3. Add users by email
4. Save

### Verify Access

Log in with assigned user and verify permissions.

## Troubleshooting

### Deployment Fails

```bash
# Check MTA build
mbt build -t gen --mtar toy-import-app.mtar -v

# Check service bindings
cf service toy-import-app-db

# Review logs
cf logs toy-import-app-srv --recent
```

### Application Not Starting

```bash
# Check events
cf events toy-import-app-srv

# Check environment variables
cf env toy-import-app-srv

# Restart application
cf restart toy-import-app-srv
```

### Database Issues

```bash
# Check HDI deployer logs
cf logs toy-import-app-db-deployer --recent

# Verify HANA instance is running
cf service toy-import-app-db
```

### Authentication Issues

```bash
# Recreate XSUAA service
cf delete-service toy-import-app-uaa
cf create-service xsuaa application toy-import-app-uaa -c xs-security.json

# Restage application
cf restage toy-import-app-srv
```

## Monitoring & Maintenance

### View Logs

```bash
# Stream logs
cf logs toy-import-app-srv

# Recent logs
cf logs toy-import-app-srv --recent
```

### Scale Application

```bash
# Scale instances
cf scale toy-import-app-srv -i 2

# Scale memory
cf scale toy-import-app-srv -m 512M
```

### Update Application

```bash
# Rebuild and redeploy
cds build --production
mbt build -t gen --mtar toy-import-app.mtar
cf deploy gen/toy-import-app.mtar
```

## Production Recommendations

1. **Use multiple instances**: Scale to at least 2 instances for HA
2. **Configure autoscaling**: Enable CF autoscaling
3. **Enable application logging**: Use SAP Application Logging service
4. **Set up monitoring**: Configure alerts in BTP Cockpit
5. **Regular backups**: Enable HANA Cloud backups
6. **Security scans**: Run regular security assessments
7. **Performance testing**: Load test before go-live

## Resources

- [SAP BTP Documentation](https://help.sap.com/docs/BTP)
- [Cloud Foundry Documentation](https://docs.cloudfoundry.org/)
- [MTA Developer Guide](https://help.sap.com/docs/BTP/65de2977205c403bbc107264b8eccf4b/d04fc0e2ad894545aebfd7126384307c.html)
