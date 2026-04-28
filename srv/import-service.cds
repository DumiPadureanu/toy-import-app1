using { com.toyplatform.imports as imports } from '../db/imports';

/**
 * Import Service - Manages supplier shipments and import operations
 */
service ImportService @(path: '/odata/v4/import') {
  
  @odata.draft.enabled
  entity Suppliers as projection on imports.Suppliers;
  
  @odata.draft.enabled
  entity Shipments as projection on imports.Shipments;
  
  entity ShipmentItems as projection on imports.ShipmentItems;
  entity ShipmentEvents as projection on imports.ShipmentEvents;
  entity ImportDocuments as projection on imports.ImportDocuments;
  
  // Custom actions
  action confirmShipmentArrival(shipmentID : UUID, actualArrivalDate : Date) returns Shipments;
  action updateShipmentStatus(shipmentID : UUID, newStatus : String) returns Shipments;
  function getShipmentsBySupplier(supplierID : UUID) returns array of Shipments;
  function getOverdueShipments() returns array of Shipments;
}
