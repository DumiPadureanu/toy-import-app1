using { com.toyplatform.notifications as notifications } from '../db/notifications';

/**
 * Notification Service - Manages notifications and alerts
 */
service NotificationService @(path: '/odata/v4/notification') {
  
  @odata.draft.enabled
  entity NotificationTemplates as projection on notifications.NotificationTemplates;
  
  entity Notifications as projection on notifications.Notifications;
  
  // Custom actions
  action sendNotification(
    templateCode : String,
    recipientType : String,
    recipientID : UUID,
    recipientEmail : String,
    recipientPhone : String,
    referenceType : String,
    referenceID : UUID,
    templateData : String // JSON string with placeholder values
  ) returns Notifications;
  
  action resendNotification(notificationID : UUID) returns Notifications;
  action markAsRead(notificationID : UUID) returns Notifications;
  
  // Bulk operations
  action sendBulkNotifications(
    templateCode : String,
    recipients : array of {
      recipientEmail : String;
      recipientPhone : String;
      templateData : String;
    }
  ) returns {
    totalSent : Integer;
    failedCount : Integer;
    notificationIDs : array of UUID;
  };
  
  // Custom functions
  function getNotificationsByRecipient(recipientType : String, recipientID : UUID) returns array of Notifications;
  function getUnreadNotifications(recipientType : String, recipientID : UUID) returns array of Notifications;
  function getFailedNotifications() returns array of Notifications;
}
