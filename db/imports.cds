namespace com.toyplatform.imports;

using { cuid, managed, Address, ContactInfo, ShipmentStatus } from '../common';
using { Currency } from '@sap/cds/common';

/**
 * Supplier entity - manages toy suppliers (primarily from China)
 */
entity Suppliers : cuid, managed {
  name            : String(255) not null;
  code            : String(50) not null;
  country         : String(100) default 'China';
  address         : Address;
  contactInfo     : ContactInfo;
  rating          : Decimal(2, 1); // 0.0 to 5.0
  isActive        : Boolean default true;
  paymentTerms    : String(100);
  notes           : LargeString;
  
  // Associations
  shipments       : Association to many Shipments on shipments.supplier = $self;
}

/**
 * Shipment entity - tracks import shipments from suppliers
 */
entity Shipments : cuid, managed {
  shipmentNumber  : String(100) not null;
  supplier        : Association to Suppliers;
  status          : ShipmentStatus default 'PENDING';
  
  // Dates
  orderDate       : Date;
  expectedArrival : Date;
  actualArrival   : Date;
  
  // Shipment details
  originPort      : String(255);
  destinationPort : String(255);
  containerNumber : String(100);
  sealNumber      : String(100);
  
  // Financial
  totalValue      : Decimal(15, 2);
  currency        : Currency;
  
  // Documents
  billOfLading    : String(500); // File path or URL
  invoice         : String(500);
  packingList     : String(500);
  
  notes           : LargeString;
  
  // Associations
  items           : Composition of many ShipmentItems on items.shipment = $self;
  events          : Composition of many ShipmentEvents on events.shipment = $self;
  documents       : Composition of many ImportDocuments on documents.shipment = $self;
}

/**
 * Shipment Items - individual products in a shipment
 */
entity ShipmentItems : cuid {
  shipment      : Association to Shipments;
  product       : Association to com.toyplatform.inventory.Products;
  quantity      : Integer not null;
  unitCost      : Decimal(15, 2);
  totalCost     : Decimal(15, 2);
  packaging     : String(100);
  notes         : String(500);
}

/**
 * Shipment Events - audit trail of shipment status changes
 */
entity ShipmentEvents : cuid, managed {
  shipment      : Association to Shipments;
  eventType     : String(100) not null; // e.g., "Departed", "Arrived at Port", "Customs Cleared"
  eventDate     : DateTime not null;
  location      : String(255);
  notes         : LargeString;
  recordedBy    : String(255);
}

/**
 * Import Documents - manage all import-related documentation
 */
entity ImportDocuments : cuid, managed {
  shipment      : Association to Shipments;
  documentType  : String(100) not null; // e.g., "Bill of Lading", "Commercial Invoice", "Certificate of Origin"
  documentNumber: String(100);
  issueDate     : Date;
  expiryDate    : Date;
  fileUrl       : String(1000);
  fileName      : String(255);
  fileSize      : Integer;
  mimeType      : String(100);
  notes         : LargeString;
}
