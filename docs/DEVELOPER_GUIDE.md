# Developer Guide

## Project Overview

Toy Import & Distribution Platform built with SAP CAP, HANA, and Fiori Elements/React.

## Technology Stack

- **Backend**: SAP CAP (Node.js), CDS, OData V4
- **Database**: SAP HANA Cloud
- **Frontend**: Fiori Elements + React with UI5 Web Components
- **Deployment**: SAP BTP (Cloud Foundry)
- **Authentication**: XSUAA

## Development Environment Setup

See [Quick Start Guide](QUICK_START.md) for detailed setup instructions.

## Project Structure

```
toy-import-app/
├── db/                    # CDS data models
│   ├── common.cds        # Shared types and aspects
│   ├── imports.cds       # Import entities
│   ├── inventory.cds     # Inventory entities
│   ├── orders.cds        # Order entities
│   ├── deliveries.cds    # Delivery entities
│   ├── customers.cds     # Customer entities
│   ├── carriers.cds      # Carrier entities
│   ├── locations.cds     # Location entities
│   ├── users.cds         # User entities
│   ├── notifications.cds # Notification entities
│   └── views.cds         # Analytics views
├── srv/                  # Services
│   ├── *-service.cds     # Service definitions
│   └── *-service.js      # Service implementations
├─ app/                   # UI applications
│   ├── fiori/           # Fiori Elements apps
│   └── react/           # Custom React components
├── src/lib/             # Utilities
│   ├── logger.js        # Logging
│   ├── validators.js    # Validation
│   ├── cache.js         # Caching
│   ├── auth.js          # Authentication helpers
│   └── queue.js         # Job queue
├── test/                # Tests
│   ├── unit/           # Unit tests
│   ├── integration/    # Integration tests
│   └── e2e/            # End-to-end tests
├── docs/               # Documentation
└── config/             # Configuration
```

## Coding Standards

### CDS Models
- Use `cuid` and `managed` aspects
- Always add `@restrict` annotations
- Use proper associations vs compositions
- Add UI annotations for Fiori

### Service Implementations
- Extend `cds.ApplicationService`
- Use `async/await` (no callbacks)
- Log all significant actions
- Validate input data
- Handle errors gracefully

### JavaScript/TypeScript
- Use ES6+ features
- Follow Airbnb style guide
- Use meaningful variable names
- Add JSDoc comments for complex functions

## Common Development Tasks

### Adding a New Entity

1. Define in `db/<module>.cds`:
```cds
entity MyEntity : cuid, managed {
  name : String(255) not null;
  // ... other fields
}
```

2. Expose in `srv/<service>.cds`:
```cds
entity MyEntities as projection on my.MyEntity;
```

3. Add handlers in `srv/<service>.js`
4. Add UI annotations
5. Test with `cds watch`

### Adding Custom Actions

1. Define in service CDS:
```cds
action myAction(param : String) returns Boolean;
```

2. Implement in service JS:
```js
this.on('myAction', async (req) => {
  const { param } = req.data;
  // Implementation
  return true;
});
```

### Adding Validations

```js
this.before('CREATE', MyEntity, async (req) => {
  if (!req.data.requiredField) {
    req.reject(400, 'requiredField is mandatory');
  }
});
```

## Testing

### Unit Tests
```bash
npm run test:unit
```

### Integration Tests
```bash
npm run test:integration
```

### E2E Tests
```bash
npm run test:e2e
```

## Debugging

### VS Code Launch Configuration

Create `.vscode/launch.json`:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "node",
      "request": "launch",
      "name": "CDS Run",
      "skipFiles": ["<node_internals>/**"],
      "program": "${workspaceFolder}/node_modules/@sap/cds/bin/cds",
      "args": ["run", "--in-memory"]
    }
  ]
}
```

### Logging

```js
const logger = require('../src/lib/logger');
logger.info('Processing order', { orderID });
logger.error('Failed to process', error);
```

## Version Control

### Git Workflow

1. Create feature branch: `git checkout -b feature/my-feature`
2. Make changes and commit: `git commit -m "feat: add new feature"`
3. Push branch: `git push origin feature/my-feature`
4. Create pull request
5. Merge after review

### Commit Message Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

## Resources

- [SAP CAP Documentation](https://cap.cloud.sap/docs/)
- [SAP HANA Cloud](https://help.sap.com/docs/HANA_CLOUD)
- [Fiori Elements](https://sapui5.hana.ondemand.com/test-resources/sap/fe/core/fpmExplorer/index.html)
- [UI5 Web Components React](https://sap.github.io/ui5-webcomponents-react/)
