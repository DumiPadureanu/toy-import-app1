namespace com.toyplatform.locations;

using { cuid, managed } from '../common';

/**
 * Geofences - geographic boundaries for tracking and alerts
 */
entity Geofences : cuid, managed {
  name           : String(255) not null;
  description    : LargeString;
  
  // Geometry
  geometryType   : String(50); // e.g., "Circle", "Polygon"
  centerLatitude : Decimal(10, 8);
  centerLongitude: Decimal(11, 8);
  radius         : Decimal(10, 2); // meters (for circle)
  polygonCoordinates : LargeString; // JSON array of lat/lng pairs (for polygon)
  
  // Type and purpose
  fenceType      : String(50); // e.g., "Warehouse", "Delivery Zone", "Restricted Area"
  isActive       : Boolean default true;
  
  // Alerts
  alertOnEntry   : Boolean default false;
  alertOnExit    : Boolean default false;
  alertRecipients: LargeString; // Comma-separated email addresses
  
  notes          : LargeString;
  
  // Associations
  zones          : Composition of many DeliveryZones on zones.geofence = $self;
}

/**
 * Delivery Zones - operational zones for route planning
 */
entity DeliveryZones : cuid, managed {
  geofence       : Association to Geofences not null;
  
  zoneName       : String(255) not null;
  zoneCode       : String(50);
  
  // Service parameters
  defaultCarrier : Association to com.toyplatform.carriers.Carriers;
  standardDeliveryDays : Integer;
  cutoffTime     : Time; // Order cutoff for same-day processing
  
  // Pricing
  deliverySurcharge : Decimal(15, 2);
  freeShippingThreshold : Decimal(15, 2);
  
  isActive       : Boolean default true;
  priority       : Integer; // For overlapping zones
  
  notes          : LargeString;
}
