namespace com.toyplatform.views;

using { com.toyplatform.orders.Orders } from '../orders';
using { com.toyplatform.deliveries.Deliveries } from '../deliveries';
using { com.toyplatform.inventory.InventoryLevels } from '../inventory';
using { com.toyplatform.imports.Shipments } from '../imports';

/**
 * Order Analytics View - aggregated order statistics
 */
define view OrderAnalytics as
  select from Orders {
    key ID,
    orderNumber,
    customer.name as customerName,
    orderDate,
    status,
    totalAmount,
    currency,
    
    // Aggregations can be added in service layer
  };

/**
 * Delivery Performance View - delivery metrics
 */
define view DeliveryPerformance as
  select from Deliveries {
    key ID,
    deliveryNumber,
    carrier.name as carrierName,
    status,
    scheduledDate,
    actualDelivery,
    
    // Calculate on-time delivery in service layer
    case 
      when actualDelivery is not null and actualDelivery <= estimatedDelivery 
      then 'On Time'
      when actualDelivery is not null and actualDelivery > estimatedDelivery
      then 'Late'
      else 'Pending'
    end as deliveryPerformance : String(20)
  };

/**
 * Inventory Status View - current inventory with alerts
 */
define view InventoryStatus as
  select from InventoryLevels {
    key ID,
    product.sku as productSKU,
    product.name as productName,
    warehouse.code as warehouseCode,
    warehouse.name as warehouseName,
    quantityOnHand,
    quantityReserved,
    quantityAvailable,
    product.reorderLevel,
    
    // Alert flags
    case 
      when quantityAvailable <= 0 then 'Out of Stock'
      when quantityAvailable <= product.reorderLevel then 'Low Stock'
      else 'In Stock'
    end as stockStatus : String(20)
  };

/**
 * Shipment Tracking View - import shipment overview
 */
define view ShipmentTracking as
  select from Shipments {
    key ID,
    shipmentNumber,
    supplier.name as supplierName,
    status,
    orderDate,
    expectedArrival,
    actualArrival,
    originPort,
    destinationPort,
    totalValue,
    currency,
    
    // Days in transit
    case 
      when actualArrival is not null 
      then datediff('day', orderDate, actualArrival)
      else datediff('day', orderDate, now())
    end as daysInTransit : Integer
  };

/**
 * Sales Summary View - sales metrics by customer
 */
define view SalesSummary as
  select from Orders {
    customer.ID as customerID,
    customer.name as customerName,
    customer.customerType,
    
    count(*) as totalOrders : Integer,
    sum(totalAmount) as totalRevenue : Decimal(15, 2),
    avg(totalAmount) as avgOrderValue : Decimal(15, 2),
    
    max(orderDate) as lastOrderDate : Date
  }
  group by 
    customer.ID,
    customer.name,
    customer.customerType;
