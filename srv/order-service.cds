using { com.toyplatform.orders as orders } from '../db/orders';
using { com.toyplatform.customers as customers } from '../db/customers';

/**
 * Order Service - Manages customer orders
 */
service OrderService @(path: '/odata/v4/order') {
  
  @odata.draft.enabled
  entity Orders as projection on orders.Orders;
  
  entity OrderItems as projection on orders.OrderItems;
  entity OrderNotes as projection on orders.OrderNotes;
  
  // Read-only customer data for selection
  @readonly
  entity Customers as projection on customers.Customers;
  
  // Custom actions
  action confirmOrder(orderID : UUID) returns Orders;
  action cancelOrder(orderID : UUID, reason : String) returns Orders;
  action addOrderNote(orderID : UUID, noteText : String, isInternal : Boolean) returns OrderNotes;
  
  // Order processing
  action processPayment(orderID : UUID, paymentMethod : String, paymentReference : String) returns Orders;
  action updateOrderStatus(orderID : UUID, newStatus : String) returns Orders;
  
  // Custom functions
  function getOrdersByCustomer(customerID : UUID) returns array of Orders;
  function getOrdersByStatus(status : String) returns array of Orders;
  function getOrdersByDateRange(startDate : Date, endDate : Date) returns array of Orders;
  function calculateOrderTotal(orderID : UUID) returns Decimal;
}
