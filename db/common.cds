namespace com.toyplatform;

/**
 * Common status codes
 */
type Status : String(20) enum {
  ACTIVE   = 'ACTIVE';
  INACTIVE = 'INACTIVE';
  DELETED  = 'DELETED';
}

type ShipmentStatus : String(30) enum {
  PENDING           = 'PENDING';
  IN_TRANSIT        = 'IN_TRANSIT';
  CUSTOMS_CLEARANCE = 'CUSTOMS_CLEARANCE';
  ARRIVED           = 'ARRIVED';
  COMPLETED         = 'COMPLETED';
  CANCELLED         = 'CANCELLED';
}

type OrderStatus : String(30) enum {
  PENDING    = 'PENDING';
  CONFIRMED  = 'CONFIRMED';
  PROCESSING = 'PROCESSING';
  SHIPPED    = 'SHIPPED';
  DELIVERED  = 'DELIVERED';
  CANCELLED  = 'CANCELLED';
}

type DeliveryStatus : String(30) enum {
  SCHEDULED  = 'SCHEDULED';
  PICKED_UP  = 'PICKED_UP';
  IN_TRANSIT = 'IN_TRANSIT';
  OUT_FOR_DELIVERY = 'OUT_FOR_DELIVERY';
  DELIVERED  = 'DELIVERED';
  FAILED     = 'FAILED';
  RETURNED   = 'RETURNED';
}

type StockMovementType : String(30) enum {
  RECEIPT    = 'RECEIPT';
  SHIPMENT   = 'SHIPMENT';
  ADJUSTMENT = 'ADJUSTMENT';
  TRANSFER   = 'TRANSFER';
  RETURN     = 'RETURN';
}

/**
 * Address type for reuse across entities
 */
type Address : {
  street       : String(255);
  city         : String(100);
  state        : String(100);
  postalCode   : String(20);
  country      : String(100);
  latitude     : Decimal(10, 8);
  longitude    : Decimal(11, 8);
}

/**
 * Contact information type
 */
type ContactInfo : {
  email : String(255);
  phone : String(50);
  fax   : String(50);
}
