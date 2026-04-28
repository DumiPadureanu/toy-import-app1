using { com.toyplatform.views as views } from '../db/views';

/**
 * Analytics Service - Provides business intelligence and reporting
 */
service AnalyticsService @(path: '/odata/v4/analytics') {
  
  @readonly
  entity OrderAnalytics as projection on views.OrderAnalytics;
  
  @readonly
  entity DeliveryPerformance as projection on views.DeliveryPerformance;
  
  @readonly
  entity InventoryStatus as projection on views.InventoryStatus;
  
  @readonly
  entity ShipmentTracking as projection on views.ShipmentTracking;
  
  @readonly
  entity SalesSummary as projection on views.SalesSummary;
  
  // Custom functions for dashboards
  function getSalesDashboard(startDate : Date, endDate : Date) returns {
    totalRevenue : Decimal;
    totalOrders : Integer;
    avgOrderValue : Decimal;
    topCustomers : array of {
      customerName : String;
      revenue : Decimal;
      orderCount : Integer;
    };
    topProducts : array of {
      productName : String;
      quantitySold : Integer;
      revenue : Decimal;
    };
  };
  
  function getInventoryDashboard() returns {
    totalProducts : Integer;
    outOfStockCount : Integer;
    lowStockCount : Integer;
    totalValue : Decimal;
    warehouseUtilization : array of {
      warehouseName : String;
      utilizationPercent : Decimal;
    };
  };
  
  function getDeliveryDashboard(startDate : Date, endDate : Date) returns {
    totalDeliveries : Integer;
    onTimeDeliveries : Integer;    lateDeliveries : Integer;
    pendingDeliveries : Integer;
    onTimeRate : Decimal;
    avgDeliveryTime : Integer;
  };
  
  function getImportDashboard(startDate : Date, endDate : Date) returns {
    totalShipments : Integer;
    completedShipments : Integer;
    inTransitShipments : Integer;
    delayedShipments : Integer;
    totalImportValue : Decimal;
    avgTransitDays : Integer;
  };
}
