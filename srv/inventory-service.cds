using { com.toyplatform.inventory as inventory } from '../db/inventory';

/**
 * Inventory Service - Manages product catalog and stock levels
 */
service InventoryService @(path: '/odata/v4/inventory') {
  
  @odata.draft.enabled
  entity Products as projection on inventory.Products;
  
  entity ProductCategories as projection on inventory.ProductCategories;
  
  @odata.draft.enabled
  entity Warehouses as projection on inventory.Warehouses;
  
  entity InventoryLevels as projection on inventory.InventoryLevels;
  entity StockMovements as projection on inventory.StockMovements;
  entity StockAdjustments as projection on inventory.StockAdjustments;
  
  // Custom actions
  action adjustStock(
    productID : UUID,
    warehouseID : UUID,
    quantity : Integer,
    reason : String
  ) returns InventoryLevels;
  
  action transferStock(
    productID : UUID,
    fromWarehouseID : UUID,
    toWarehouseID : UUID,
    quantity : Integer
  ) returns Boolean;
  
  action reserveStock(productID : UUID, warehouseID : UUID, quantity : Integer) returns Boolean;
  action releaseStock(productID : UUID, warehouseID : UUID, quantity : Integer) returns Boolean;
  
  // Custom functions
  function getLowStockProducts(warehouseID : UUID) returns array of Products;
  function getProductAvailability(productID : UUID) returns {
    productID : UUID;
    totalAvailable : Integer;
    warehouseBreakdown : array of {
      warehouseID : UUID;
      warehouseName : String;
      available : Integer;
    };
  };
}
