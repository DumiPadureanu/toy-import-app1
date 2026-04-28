# Toy Import & Distribution Platform

SAP CAP-based application for managing toy imports from China, inventory, customer orders, and delivery tracking.

## Tech Stack

- **Backend**: SAP CAP (Node.js), CDS, OData V4
- **Database**: SAP HANA Cloud
- **UI**: Fiori Elements + UI5 Web Components for React
- **Deployment**: SAP BTP (Cloud Foundry)

## Quick Start

### Prerequisites
- Node.js ≥ 18.0.0
- npm ≥ 8.0.0
- SAP HANA Database Explorer access
- SAP BTP account (for deployment)

### Installation

```bash
# Clone and install
git clone <repository-url>
cd toy-import-app
npm install

# Configure HANA connection
cp .env.example .env
# Edit .env with your HANA credentials

# Run locally
npm run dev
```

### Access

- **CAP Server**: http://localhost:4004
- **Fiori Launchpad**: http://localhost:4004/fiori.html
- **API Documentation**: http://localhost:4004/$metadata

## Project Structure

```
toy-import-app/
├── db/                    # CDS data models
├── srv/                   # Service definitions & implementations
├── app/                   # UI applications
│   ├── fiori/            # Fiori Elements pages
│   └── react/            # Custom React components
├── src/lib/              # Utilities
├── test/                 # Test suites
├── docs/                 # Documentation
└── config/               # Configuration files
```

## Development

```bash
# Development mode with hot reload
npm run dev

# Run tests
npm test

# Lint & format
npm run lint
npm run format

# Build for production
npm run build
```

## Deployment

See [docs/DEPLOYMENT.md](docs/DEPLOYMENT.md) for SAP BTP deployment instructions.

## Documentation

- [Quick Start Guide](docs/QUICK_START.md)
- [HANA Setup](docs/HANA_SETUP.md)
- [Fiori Development](docs/FIORI_DEV.md)
- [API Specification](docs/API_SPECIFICATION.md)
- [Developer Guide](docs/DEVELOPER_GUIDE.md)

## Architecture

See [ARCHITECTURE_PLAN.md](../ARCHITECTURE_PLAN.md) for detailed architecture documentation.

## License

Proprietary - Internal Use Only
