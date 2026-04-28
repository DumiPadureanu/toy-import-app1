# Quick Start Guide

## Prerequisites

- Node.js ≥ 18.0.0
- npm ≥ 8.0.0
- SAP HANA Database access (Cloud or on-premise)
- VS Code (recommended)

## Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd toy-import-app
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Configure HANA connection**
   ```bash
   cp .env.example .env
   # Edit .env with your HANA credentials
   ```

4. **Deploy database schema**
   ```bash
   cds deploy --to hana
   ```

5. **Start development server**
   ```bash
   npm run dev
   ```

6. **Access the application**
   - CAP Server: http://localhost:4004
   - Fiori Launchpad: http://localhost:4004/fiori.html
   - API Metadata: http://localhost:4004/$metadata

## Development Workflow

### Running Tests
```bash
npm test                 # All tests
npm run test:unit        # Unit tests only
npm run test:integration # Integration tests
```

### Linting & Formatting
```bash
npm run lint            # Check code quality
npm run lint:fix        # Auto-fix issues
npm run format          # Format code with Prettier
```

### Building for Production
```bash
npm run build           # Build MTA archive
```

## Project Structure

```
toy-import-app/
├── db/              # CDS data models
├── srv/             # Service definitions & implementations
├── app/             # UI applications (Fiori + React)
├── test/            # Test suites
├── docs/            # Documentation
├── config/          # Configuration files
└── src/lib/         # Utility libraries
```

## Common Tasks

### Adding a New Entity
1. Define entity in `db/<module>.cds`
2. Expose in service `srv/<service>.cds`
3. Add validation in service implementation
4. Create Fiori page or React component

### Adding a New Service
1. Create service definition `srv/<name>-service.cds`
2. Create implementation `srv/<name>-service.js`
3. Add to `package.json` cds.requires (if external)
4. Test with $metadata endpoint

## Troubleshooting

### HANA Connection Issues
- Check .env credentials
- Verify network connectivity
- Confirm HDI container exists

### Port Already in Use
```bash
lsof -ti:4004 | xargs kill  # Kill process on port 4004
```

### Module Not Found
```bash
rm -rf node_modules package-lock.json
npm install
```

## Next Steps

- Review [HANA Setup Guide](HANA_SETUP.md)
- Read [Fiori Development Guide](FIORI_DEV.md)
- Check [API Specification](API_SPECIFICATION.md)
