namespace com.toyplatform.deliveries;

using { cuid, managed, DeliveryStatus, Address } from '../common';
using { Orders } from '../orders';
using { Warehouses } from '../inventory';
using { Carriers } from '../carriers';

/**
 * Deliveries - shipment to customers
 */
entity Deliveries : cuid, managed {
  deliveryNumber : String(100) not null;
  order          : Association to Orders not null;
  warehouse      : Association to Warehouses;
  carrier        : Association to Carriers;
  
  // Status
  status         : DeliveryStatus default 'SCHEDULED';
  
  // Dates
  scheduledDate  : DateTime;
  pickupDate     : DateTime;
  estimatedDelivery : DateTime;
  actualDelivery : DateTime;
  
  // Delivery address
  deliveryAddress: Address;
  recipientName  : String(255);
  recipientPhone : String(50);
  
  // Tracking
  trackingNumber : String(100);
  trackingUrl    : String(1000);
  
  // Proof of Delivery
  signatureUrl   : String(1000);
  photoUrl       : String(1000);
  deliveredToName: String(255);
  
  // Route
  routeID        : UUID;
  stopNumber     : Integer; // Sequence in the route
  
  notes          : LargeString;
  driverNotes    : LargeString;
  
  // Associations
  items          : Composition of many DeliveryItems on items.delivery = $self;
  events         : Composition of many DeliveryEvents on events.delivery = $self;
  route          : Association to DeliveryRoutes;
}

/**
 * Delivery Items - products in a delivery
 */
entity DeliveryItems : cuid {
  delivery       : Association to Deliveries not null;
  orderItem      : Association to com.toyplatform.orders.OrderItems not null;
  
  quantity       : Integer not null;
  packaging      : String(100);
  
  // Quality checks
  isInspected    : Boolean default false;
  isDamaged      : Boolean default false;
  damageNotes    : String(500);
}

/**
 * Delivery Events - tracking events during delivery
 */
entity DeliveryEvents : cuid, managed {
  delivery       : Association to Deliveries not null;
  
  eventType      : String(100) not null; // e.g., "Picked Up", "In Transit", "Out for Delivery", "Delivered"
  eventTime      : DateTime not null;
  location       : String(255);
  latitude       : Decimal(10, 8);
  longitude      : Decimal(11, 8);
  
  notes          : LargeString;
  recordedBy     : String(255);
}

/**
 * Delivery Routes - planned delivery routes
 */
entity DeliveryRoutes : cuid, managed {
  routeNumber    : String(100) not null;
  routeName      : String(255);
  
  routeDate      : Date not null;
  startTime      : Time;
  endTime        : Time;
  
  driver         : String(255);
  vehicle        : String(100);
  
  status         : String(50); // e.g., "Planned", "In Progress", "Completed"
  
  totalDistance  : Decimal(10, 2); // km
  totalDuration  : Integer; // minutes
  
  // Associations
  deliveries     : Association to many Deliveries on deliveries.route = $self;
  routePoints    : Composition of many RoutePoints on routePoints.route = $self;
}

/**
 * Route Points - waypoints in a delivery route
 */
entity RoutePoints : cuid {
  route          : Association to DeliveryRoutes not null;
  
  sequenceNumber : Integer not null;
  delivery       : Association to Deliveries;
  
  address        : Address;
  
  estimatedArrival : DateTime;
  actualArrival  : DateTime;
  
  durationAtStop : Integer; // minutes
  notes          : String(500);
}

/**
 * Geolocation Points - real-time GPS tracking
 */
entity GeolocationPoints : cuid {
  delivery       : Association to Deliveries;
  route          : Association to DeliveryRoutes;
  
  timestamp      : DateTime not null;
  latitude       : Decimal(10, 8) not null;
  longitude      : Decimal(11, 8) not null;
  accuracy       : Decimal(8, 2); // meters
  
  speed          : Decimal(6, 2); // km/h
  heading        : Integer; // degrees 0-360
  
  deviceID       : String(100);
}
