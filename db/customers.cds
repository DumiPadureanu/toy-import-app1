namespace com.toyplatform.customers;

using { cuid, managed, Address, ContactInfo } from '../common';

/**
 * Customers - toy buyers/retailers
 */
entity Customers : cuid, managed {
  customerNumber : String(100) not null;
  name           : String(255) not null;
  customerType   : String(50); // e.g., "Retail", "Wholesale", "B2B"
  
  // Tax and registration
  taxID          : String(100);
  registrationNumber : String(100);
  
  // Contact
  contactInfo    : ContactInfo;
  
  // Credit and payment  
  creditLimit    : Decimal(15, 2);
  creditUsed     : Decimal(15, 2);
  paymentTerms   : String(100);
  
  // Status
  isActive       : Boolean default true;
  rating         : Decimal(2, 1); // 0.0 to 5.0
  
  // Preferences
  preferredLanguage : String(10);
  notes          : LargeString;
  
  // Associations
  addresses      : Composition of many CustomerAddresses on addresses.customer = $self;
  contacts       : Composition of many CustomerContacts on contacts.customer = $self;
  orders         : Association to many com.toyplatform.orders.Orders on orders.customer = $self;
}

/**
 * Customer Addresses - shipping and billing addresses
 */
entity CustomerAddresses : cuid, managed {
  customer       : Association to Customers not null;
  
  addressType    : String(50) not null; // "Billing", "Shipping", "Both"
  addressName    : String(255); // e.g., "Head Office", "Warehouse 1"
  
  address        : Address;
  
  isDefault      : Boolean default false;
  isActive       : Boolean default true;
  
  deliveryInstructions : LargeString;
}

/**
 * Customer Contacts - contact persons at customer organizations
 */
entity CustomerContacts : cuid, managed {
  customer       : Association to Customers not null;
  
  firstName      : String(100);
  lastName       : String(100);
  title          : String(50); // e.g., "Purchasing Manager"
  department     : String(100);
  
  contactInfo    : ContactInfo;
  
  isPrimary      : Boolean default false;
  isActive       : Boolean default true;
  
  notes          : String(500);
}
