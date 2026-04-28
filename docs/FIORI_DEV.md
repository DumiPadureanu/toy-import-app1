# Fiori Elements Development Guide

## Overview

This project uses SAP Fiori Elements for standard CRUD pages and custom React components for complex interactive features.

## Fiori Elements Architecture

**When to Use Fiori Elements**:
- Standard list and detail pages
- Form-based data entry
- Master-detail patterns
- Standard search and filter

**When to Use Custom React**:
- Interactive dashboards
- Real-time maps and tracking
- Custom charts and visualizations
- Complex workflows

##Future Implementation

Fiori Elements pages will be scaffolded using SAP Fiori tools:

```bash
# Install Fiori generator
npm install -g @sap/generator-fiori

# Generate List Report + Object Page
fiori generate
```

## Planned Fiori Apps

1. **Suppliers App** - Supplier management
2. **Shipments App** - Import tracking
3. **Products App** - Product catalog
4. **Warehouses App** - Warehouse management
5. **Inventory App** - Stock levels
6. **Customers App** - Customer profiles
7. **Orders App** - Order processing
8. **Users App** - User administration

## CDS Annotations for Fiori

All entities include UI annotations:

```cds
annotate OrderService.Orders with @(
  UI.LineItem: [
    { Value: orderNumber, Label: 'Order Number' },
    { Value: customer.name, Label: 'Customer' },
    { Value: status, Label: 'Status' },
    { Value: totalAmount, Label: 'Total' }
  ],
  UI.HeaderInfo: {
    TypeName: 'Order',
    TypeNamePlural: 'Orders',
    Title: { Value: orderNumber }
  }
);
```

## Development Workflow

1. Define UI annotations in CDS
2. Generate Fiori app with generator
3. Customize annotations as needed
4. Test in Fiori Launchpad
5. Deploy to BTP

## Resources

- [Fiori Elements Documentation](https://sapui5.hana.ondemand.com/test-resources/sap/fe/core/fpmExplorer/index.html)
- [CAP Fiori Guide](https://cap.cloud.sap/docs/advanced/fiori)
- [UI5 Fiori Guidelines](https://experience.sap.com/fiori-design-web/)
