namespace com.toyplatform.notifications;

using { cuid, managed } from '../common';

/**
 * Notification Templates - reusable notification templates
 */
entity NotificationTemplates : cuid, managed {
  code           : String(50) not null;
  name           : String(255) not null;
  description    : LargeString;
  
  // Template details
  notificationType : String(50) not null; // e.g., "Email", "SMS", "In-App", "Push"
  subject        : String(500); // For email
  bodyTemplate   : LargeString not null; // Template with placeholders like {{orderNumber}}
  
  // Metadata
  triggerEvent   : String(100); // e.g., "OrderConfirmed", "ShipmentArrived"
  language       : String(10) default 'en';
  
  isActive       : Boolean default true;
  
  // Associations
  notifications  : Association to many Notifications on notifications.template = $self;
}

/**
 * Notifications - sent notifications history
 */
entity Notifications : cuid, managed {
  template       : Association to NotificationTemplates;
  
  // Recipient
  recipientType  : String(50); // e.g., "Customer", "Supplier", "User"
  recipientID    : UUID;
  recipientEmail : String(255);
  recipientPhone : String(50);
  
  // Notification details
  notificationType : String(50); // e.g., "Email", "SMS"
  subject        : String(500);
  body           : LargeString;
  
  // Status
  status         : String(50); // e.g., "Pending", "Sent", "Failed", "Delivered", "Read"
  sentAt         : DateTime;
  deliveredAt    : DateTime;
  readAt         : DateTime;
  
  // Error handling
  failureReason  : String(500);
  retryCount     : Integer default 0;
  maxRetries     : Integer default 3;
  
  // Reference
  referenceType  : String(50); // e.g., "Order", "Shipment", "Delivery"
  referenceID    : UUID;
  
  notes          : LargeString;
}
