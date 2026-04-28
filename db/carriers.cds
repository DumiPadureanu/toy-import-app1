namespace com.toyplatform.carriers;

using { cuid, managed, Currency } from '@sap/cds/common';
using { com.toyplatform.ContactInfo as ContactInfo } from './common';
using { com.toyplatform.deliveries.Deliveries as Deliveries } from './deliveries';

/**
 * Carriers - shipping and logistics companies
 */
entity Carriers : cuid, managed {
  code           : String(50) not null;
  name           : String(255) not null;
  
  carrierType    : String(50); // e.g., "Express", "Standard", "Local"
  
  contactInfo    : ContactInfo;
  
  // Service details
  serviceAreas   : LargeString; // Comma-separated list or JSON
  trackingUrl    : String(1000);
  apiEndpoint    : String(1000);
  apiKey         : String(255); // Encrypted
  
  // Performance metrics
  rating         : Decimal(2, 1); // 0.0 to 5.0
  onTimeDeliveryRate : Decimal(5, 2); // Percentage
  
  isActive       : Boolean default true;
  notes          : LargeString;
  
  // Associations
  rates          : Composition of many CarrierRates on rates.carrier = $self;
  deliveries     : Association to many Deliveries on deliveries.carrier = $self;
}

/**
 * Carrier Rates - shipping rates and service levels
 */
entity CarrierRates : cuid, managed {
  carrier        : Association to Carriers not null;
  
  serviceName    : String(255) not null; // e.g., "Express", "Economy", "Same Day"
  serviceCode    : String(50);
  
  // Rate structure
  rateType       : String(50); // e.g., "Flat", "Weight-based", "Distance-based"
  baseRate       : Decimal(15, 2);
  currency       : Currency;
  
  // Weight tiers (for weight-based)
  minWeight      : Decimal(10, 3);
  maxWeight      : Decimal(10, 3);
  
  // Distance tiers (for distance-based)
  minDistance    : Decimal(10, 2);
  maxDistance    : Decimal(10, 2);
  
  // Estimated delivery time
  transitDays    : Integer;
  
  isActive       : Boolean default true;
  effectiveDate  : Date;
  expiryDate     : Date;
}
