namespace com.toyplatform.orders;

using { cuid, managed, OrderStatus } from '../common';
using { Currency } from '@sap/cds/common';
using { Customers } from '../customers';
using { Products } from '../inventory';

/**
 * Orders - customer orders
 */
entity Orders : cuid, managed {
  orderNumber    : String(100) not null;
  customer       : Association to Customers not null;
  
  // Order dates
  orderDate      : Date not null;
  requestedDeliveryDate : Date;
  confirmedDeliveryDate : Date;
  
  // Status
  status         : OrderStatus default 'PENDING';
  
  // Financial
  subtotal       : Decimal(15, 2);
  taxAmount      : Decimal(15, 2);
  shippingCost   : Decimal(15, 2);
  discountAmount : Decimal(15, 2);
  totalAmount    : Decimal(15, 2);
  currency       : Currency;
  
  // Payment
  paymentStatus  : String(50); // e.g., "Pending", "Paid", "Partial"
  paymentMethod  : String(50);
  paymentDate    : Date;
  
  // Shipping details
  shippingAddress: LargeString;
  shippingMethod : String(100);
  trackingNumber : String(100);
  
  notes          : LargeString;
  internalNotes  : LargeString;
  
  // Associations
  items          : Composition of many OrderItems on items.order = $self;
  notes_         : Composition of many OrderNotes on notes_.order = $self;
}

/**
 * Order Items - line items in an order
 */
entity OrderItems : cuid {
  order          : Association to Orders not null;
  product        : Association to Products not null;
  
  quantity       : Integer not null;
  unitPrice      : Decimal(15, 2) not null;
  discount       : Decimal(15, 2);
  taxAmount      : Decimal(15, 2);
  lineTotal      : Decimal(15, 2); // (quantity * unitPrice) - discount + tax
  
  // Fulfillment
  quantityShipped: Integer default 0;
  quantityPending: Integer; // = quantity - quantityShipped
  
  notes          : String(500);
}

/**
 * Order Notes - comments and communication history
 */
entity OrderNotes : cuid, managed {
  order          : Association to Orders not null;
  
  noteType       : String(50); // e.g., "Customer Request", "Internal", "Issue"
  noteText       : LargeString not null;
  
  isInternal     : Boolean default false;
  isResolved     : Boolean default false;
}
