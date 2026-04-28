namespace com.toyplatform.inventory;

using { cuid, managed, StockMovementType } from '../common';
using { Currency } from '@sap/cds/common';

/**
 * Product Categories - hierarchical product classification
 */
entity ProductCategories : cuid, managed {
  name          : String(255) not null;
  code          : String(50) not null;
  description   : LargeString;
  parentCategory: Association to ProductCategories;
  isActive      : Boolean default true;
  
  // Associations
  products      : Association to many Products on products.category = $self;
}

/**
 * Products - toy product catalog
 */
entity Products : cuid, managed {
  sku           : String(100) not null;
  name          : String(255) not null;
  description   : LargeString;
  category      : Association to ProductCategories;
  
  // Physical properties
  weight        : Decimal(10, 3); // kg
  dimensions    : String(100); // e.g., "30x20x15 cm"
  color         : String(50);
  material      : String(100);
  
  // Pricing
  costPrice     : Decimal(15, 2);
  sellingPrice  : Decimal(15, 2);
  currency      : Currency;
  
  // Inventory thresholds
  reorderLevel  : Integer;
  safetyStock   : Integer;
  
  // Product status
  isActive      : Boolean default true;
  discontinuedDate : Date;
  
  // Images and media
  imageUrl      : String(1000);
  thumbnailUrl  : String(1000);
  
  // Associations
  inventoryLevels : Association to many InventoryLevels on inventoryLevels.product = $self;
  stockMovements  : Association to many StockMovements on stockMovements.product = $self;
}

/**
 * Warehouses - storage locations
 */
entity Warehouses : cuid, managed {
  code          : String(50) not null;
  name          : String(255) not null;
  type          : String(50); // e.g., "Main", "Regional", "Transit"
  
  // Address
  street        : String(255);
  city          : String(100);
  state         : String(100);
  postalCode    : String(20);
  country       : String(100);
  latitude      : Decimal(10, 8);
  longitude     : Decimal(11, 8);
  
  // Capacity
  capacity      : Integer; // Total capacity in units/pallets
  currentUtilization : Decimal(5, 2); // Percentage
  
  isActive      : Boolean default true;
  
  // Contact
  managerName   : String(255);
  phone         : String(50);
  email         : String(255);
  
  // Associations
  inventoryLevels : Association to many InventoryLevels on inventoryLevels.warehouse = $self;
}

/**
 * Inventory Levels - current stock at each warehouse
 */
entity InventoryLevels : cuid, managed {
  product       : Association to Products not null;
  warehouse     : Association to Warehouses not null;
  
  quantityOnHand    : Integer not null default 0;
  quantityReserved  : Integer not null default 0;
  quantityAvailable : Integer not null default 0; // = onHand - reserved
  
  lastStockCheck    : DateTime;
  lastRestockDate   : Date;
  
  // Calculated field
  virtual daysUntilReorder : Integer;
}

/**
 * Stock Movements - audit trail of all inventory changes
 */
entity StockMovements : cuid, managed {
  product       : Association to Products not null;
  warehouse     : Association to Warehouses not null;
  
  movementType  : StockMovementType not null;
  quantity      : Integer not null;
  
  // Reference documents
  referenceType : String(50); // e.g., "Shipment", "Order", "Adjustment"
  referenceID   : UUID;
  
  movementDate  : DateTime not null;
  notes         : LargeString;
}

/**
 * Stock Adjustments - manual inventory adjustments
 */
entity StockAdjustments : cuid, managed {
  product       : Association to Products not null;
  warehouse     : Association to Warehouses not null;
  
  quantityBefore: Integer not null;
  quantityAfter : Integer not null;
  difference    : Integer not null;
  
  reason        : String(255) not null; // e.g., "Damaged", "Lost", "Physical Count Correction"
  adjustmentDate: DateTime not null;
  approvedBy    : String(255);
  notes         : LargeString;
}
