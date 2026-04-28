using { com.toyplatform.deliveries as deliveries } from '../db/deliveries';

/**
 * Tracking Service - Real-time tracking for deliveries and shipments
 */
service TrackingService @(path: '/odata/v4/tracking') {
  
  entity Deliveries as projection on deliveries.Deliveries {
    *, 
    // Exclude sensitive internal fields
    except { driverNotes, internalNotes }
  };
  
  entity DeliveryEvents as projection on deliveries.DeliveryEvents;
  entity GeolocationPoints as projection on deliveries.GeolocationPoints;
  
  // Custom actions for real-time updates
  action updateLocation(
    deliveryID : UUID,
    latitude : Decimal,
    longitude : Decimal,
    accuracy : Decimal,
    speed : Decimal,
    heading : Integer
  ) returns GeolocationPoints;
  
  action addTrackingEvent(
    deliveryID : UUID,
    eventType : String,
    eventTime : DateTime,
    location : String,
    latitude : Decimal,
    longitude : Decimal,
    notes : String
  ) returns DeliveryEvents;
  
  // Public tracking functions
  function trackDelivery(trackingNumber : String) returns {
    deliveryNumber : String;
    status : String;
    scheduledDate : DateTime;
    estimatedDelivery : DateTime;
    currentLocation : String;
    events : array of {
      eventType : String;
      eventTime : DateTime;
      location : String;
    };
  };
  
  function getDeliveryRoute(deliveryID : UUID) returns {
    deliveryNumber : String;
    origin : String;
    destination : String;
    currentLocation : {
      latitude : Decimal;
      longitude : Decimal;
      timestamp : DateTime;
    };
    route : array of {
      latitude : Decimal;
      longitude : Decimal;
      timestamp : DateTime;
    };
  };
  
  function getActiveDeliveriesMap() returns array of {
    deliveryID : UUID;
    deliveryNumber : String;
    status : String;
    latitude : Decimal;
    longitude : Decimal;
    lastUpdate : DateTime;
  };
}
