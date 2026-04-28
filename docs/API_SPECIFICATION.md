# API Specification

## Base URL

- **Development**: `http://localhost:4004/odata/v4`
- **Production**: `https://<your-app>.cfapps.eu10.hana.ondemand.com/odata/v4`

## Available Services

### 1. Import Service
**Path**: `/import`

**Entities**:
- `Suppliers` - Toy suppliers (CRUD + Draft)
- `Shipments` - Import shipments (CRUD + Draft)
- `ShipmentItems` - Shipment line items
- `ShipmentEvents` - Shipment tracking events
- `ImportDocuments` - Import documentation

**Actions**:
- `confirmShipmentArrival(shipmentID, actualArrivalDate)` - Confirm shipment arrival
- `updateShipmentStatus(shipmentID, newStatus)` - Update shipment status

**Functions**:
- `getShipmentsBySupplier(supplierID)` - Get shipments for a supplier
- `getOverdueShipments()` - Get overdue shipments

---

### 2. Inventory Service
**Path**: `/inventory`

**Entities**:
- `Products` - Product catalog (CRUD + Draft)
- `ProductCategories` - Product categories
- `Warehouses` - Warehouse locations (CRUD + Draft)
- `InventoryLevels` - Current stock levels
- `StockMovements` - Stock movement history
- `StockAdjustments` - Manual adjustments

**Actions**:
- `adjustStock(productID, warehouseID, quantity, reason)` - Adjust stock quantity
- `transferStock(productID, fromWarehouseID, toWarehouseID, quantity)` - Transfer between warehouses
- `reserveStock(productID, warehouseID, quantity)` - Reserve stock for order
- `releaseStock(productID, warehouseID, quantity)` - Release reserved stock

**Functions**:
- `getLowStockProducts(warehouseID)` - Get products below reorder level
- `getProductAvailability(productID)` - Get stock availability across warehouses

---

### 3. Order Service
**Path**: `/order`

**Entities**:
- `Orders` - Customer orders (CRUD + Draft)
- `OrderItems` - Order line items
- `OrderNotes` - Order comments
- `Customers` - Customer data (read-only)

**Actions**:
- `confirmOrder(orderID)` - Confirm an order
- `cancelOrder(orderID, reason)` - Cancel an order
- `addOrderNote(orderID, noteText, isInternal)` - Add a note
- `processPayment(orderID, paymentMethod, paymentReference)` - Record payment
- `updateOrderStatus(orderID, newStatus)` - Update order status

**Functions**:
- `getOrdersByCustomer(customerID)` - Get customer orders
- `getOrdersByStatus(status)` - Filter by status
- `getOrdersByDateRange(startDate, endDate)` - Filter by date
- `calculateOrderTotal(orderID)` - Calculate order total

---

### 4. Delivery Service
**Path**: `/delivery`

**Entities**:
- `Deliveries` - Deliveries (CRUD + Draft)
- `DeliveryItems` - Delivery line items
- `DeliveryEvents` - Tracking events
- `DeliveryRoutes` - Planned routes
- `RoutePoints` - Route waypoints
- `GeolocationPoints` - GPS tracking data
- `Carriers` - Shipping carriers (read-only)
- `CarrierRates` - Carrier rates (read-only)

**Actions**:
- `scheduleDelivery(orderID, warehouseID, carrierID, scheduledDate)` - Schedule delivery
- `updateDeliveryStatus(deliveryID, newStatus)` - Update status
- `recordProofOfDelivery(deliveryID, signatureUrl, photoUrl, receiverName)` - Record POD
- `trackLocation(deliveryID, latitude, longitude)` - Update GPS location
- `createRoute(routeDate, driver, vehicle)` - Create delivery route
- `addDeliveryToRoute(routeID, deliveryID, sequenceNumber)` - Add to route
- `optimizeRoute(routeID)` - Optimize route (placeholder)

**Functions**:
- `getDeliveriesByRoute(routeID)` - Get route deliveries
- `getActiveDeliveries()` - Get in-progress deliveries
- `getDeliveryHistory(deliveryID)` - Get event history
- `estimateDeliveryTime(deliveryID)` - Estimate ETA

---

### 5. Customer Service
**Path**: `/customer`

**Entities**:
- `Customers` - Customer profiles (CRUD + Draft)
- `CustomerAddresses` - Customer addresses
- `CustomerContacts` - Contact persons

**Actions**:
- `activateCustomer(customerID)` - Activate customer
- `deactivateCustomer(customerID, reason)` - Deactivate customer
- `updateCreditLimit(customerID, newLimit)` - Update credit limit
- `addAddress(...)` - Add new address
- `setDefaultAddress(addressID)` - Set default address
- `addContact(...)` - Add contact person

**Functions**:
- `getCustomersByType(customerType)` - Filter by type
- `getCustomerCreditStatus(customerID)` - Get credit info
- `searchCustomers(searchTerm)` - Search by name/number

---

### 6. Analytics Service
**Path**: `/analytics`

**Entities** (Read-only):
- `OrderAnalytics` - Order statistics
- `DeliveryPerformance` - Delivery metrics
- `InventoryStatus` - Stock status
- `ShipmentTracking` - Import tracking
- `SalesSummary` - Sales by customer

**Functions**:
- `getSalesDashboard(startDate, endDate)` - Sales KPIs
- `getInventoryDashboard()` - Inventory KPIs
- `getDeliveryDashboard(startDate, endDate)` - Delivery KPIs
- `getImportDashboard(startDate, endDate)` - Import KPIs

---

### 7. Tracking Service
**Path**: `/tracking`

**Entities**:
- `Deliveries` - Public delivery info (read-only)
- `DeliveryEvents` - Tracking events
- `GeolocationPoints` - GPS data

**Actions**:
- `updateLocation(deliveryID, latitude, longitude, ...)` - Update GPS
- `addTrackingEvent(deliveryID, eventType, ...)` - Add event

**Functions**:
- `trackDelivery(trackingNumber)` - Public tracking
- `getDeliveryRoute(deliveryID)` - Get route map
- `getActiveDeliveriesMap()` - Get all active on map

---

### 8. Notification Service
**Path**: `/notification`

**Entities**:
- `NotificationTemplates` - Templates (CRUD + Draft)
- `Notifications` - Sent notifications

**Actions**:
- `sendNotification(...)` - Send notification
- `resendNotification(notificationID)` - Resend failed
- `markAsRead(notificationID)` - Mark as read
- `sendBulkNotifications(...)` - Bulk send

**Functions**:
- `getNotificationsByRecipient(recipientType, recipientID)` - Get by recipient
- `getUnreadNotifications(recipientType, recipientID)` - Get unread
- `getFailedNotifications()` - Get failed

---

### 9. Upload Service
**Path**: `/upload`

**Actions**:
- `uploadImportDocument(...)` - Upload import doc
- `uploadProofOfDelivery(...)` - Upload POD
- `uploadProductImage(...)` - Upload product image

**Functions**:
- `getFile(fileUrl)` - Download file
- `deleteFile(fileUrl)` - Delete file

---

## Authentication

All endpoints require XSUAA authentication except public tracking endpoints.

**Headers**:
```
Authorization: Bearer <JWT_TOKEN>
```

**Roles**:
- `Administrator` - Full access
- `Manager` - Manage operations
- `User` - Standard access
- `Viewer` - Read-only

## Error Responses

```json
{
  "error": {
    "code": "400",
    "message": "Validation failed",
    "details": [
      {
        "field": "customerID",
        "message": "Required field missing"
      }
    ]
  }
}
```

## Rate Limiting

- 100 requests per minute per user
- 1000 requests per minute per IP

## Pagination

```
GET /odata/v4/order/Orders?$top=50&$skip=100
```

## Filtering

```
GET /odata/v4/order/Orders?$filter=status eq 'PENDING'
```

## Sorting

```
GET /odata/v4/order/Orders?$orderby=orderDate desc
```

## Expanding Relations

```
GET /odata/v4/order/Orders?$expand=items,customer
```
