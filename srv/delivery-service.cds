using { com.toyplatform.deliveries as deliveries } from '../db/deliveries';
using { com.toyplatform.carriers as carriers } from '../db/carriers';

/**
 * Delivery Service - Manages deliveries and tracking
 */
service DeliveryService @(path: '/odata/v4/delivery') {
  
  @odata.draft.enabled
  entity Deliveries as projection on deliveries.Deliveries;
  
  entity DeliveryItems as projection on deliveries.DeliveryItems;
  entity DeliveryEvents as projection on deliveries.DeliveryEvents;
  entity DeliveryRoutes as projection on deliveries.DeliveryRoutes;
  entity RoutePoints as projection on deliveries.RoutePoints;
  entity GeolocationPoints as projection on deliveries.GeolocationPoints;
  
  // Read-only carrier data
  @readonly
  entity Carriers as projection on carriers.Carriers;
  
  @readonly
  entity CarrierRates as projection on carriers.CarrierRates;
  
  // Custom actions
  action scheduleDelivery(
    orderID : UUID,
    warehouseID : UUID,
    carrierID : UUID,
    scheduledDate : DateTime
  ) returns Deliveries;
  
  action updateDeliveryStatus(deliveryID : UUID, newStatus : String) returns Deliveries;
  action recordProofOfDelivery(
    deliveryID : UUID,
    signatureUrl : String,
    photoUrl : String,
    receiverName : String
  ) returns Deliveries;
  
  action trackLocation(deliveryID : UUID, latitude : Decimal, longitude : Decimal) returns GeolocationPoints;
  
  // Route management
  action createRoute(routeDate : Date, driver : String, vehicle : String) returns DeliveryRoutes;
  action addDeliveryToRoute(routeID : UUID, deliveryID : UUID, sequenceNumber : Integer) returns Boolean;
  action optimizeRoute(routeID : UUID) returns DeliveryRoutes;
  
  // Custom functions
  function getDeliveriesByRoute(routeID : UUID) returns array of Deliveries;
  function getActiveDeliveries() returns array of Deliveries;
  function getDeliveryHistory(deliveryID : UUID) returns array of DeliveryEvents;
  function estimateDeliveryTime(deliveryID : UUID) returns DateTime;
}
