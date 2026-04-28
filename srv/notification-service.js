const cds = require('@sap/cds');
const { SELECT, INSERT, UPDATE } = cds.ql;

module.exports = class NotificationService extends cds.ApplicationService {
  async init() {
    const { Notifications, NotificationTemplates } = this.entities;

    this.on('sendNotification', async (req) => {
      const {
        templateCode,
        recipientType,
        recipientID,
        recipientEmail,
        recipientPhone,
        referenceType,
        referenceID,
        templateData
      } = req.data;

      const template = await SELECT.one.from(NotificationTemplates).where({ code: templateCode });
      if (!template) {
        req.reject(404, `Template ${templateCode} not found`);
      }

      // Parse and replace placeholders in template
      let body = template.bodyTemplate;
      if (templateData) {
        const data = JSON.parse(templateData);
        Object.keys(data).forEach(key => {
          body = body.replace(new RegExp(`{{${key}}}`, 'g'), data[key]);
        });
      }

      const notification = await INSERT.into(Notifications).entries({
        template_ID: template.ID,
        recipientType,
        recipientID,
        recipientEmail,
        recipientPhone,
        notificationType: template.notificationType,
        subject: template.subject,
        body,
        status: 'Pending',
        referenceType,
        referenceID
      });

      // TODO: Send actual notification via email/SMS service

      return notification;
    });

    this.on('resendNotification', async (req) => {
      const { notificationID } = req.data;
      await UPDATE(Notifications).set({ status: 'Pending', retryCount: { '+=': 1 } }).where({ ID: notificationID });
      return await SELECT.one.from(Notifications).where({ ID: notificationID });
    });

    this.on('markAsRead', async (req) => {
      const { notificationID } = req.data;
      await UPDATE(Notifications).set({ status: 'Read', readAt: new Date() }).where({ ID: notificationID });
      return await SELECT.one.from(Notifications).where({ ID: notificationID });
    });

    this.on('sendBulkNotifications', async (req) => {
      const { recipients } = req.data;
      // TODO: Implement bulk sending
      return {
        totalSent: recipients.length,
        failedCount: 0,
        notificationIDs: []
      };
    });

    this.on('getNotificationsByRecipient', async (req) => {
      const { recipientType, recipientID } = req.data;
      return await SELECT.from(Notifications).where({ recipientType, recipientID });
    });

    this.on('getUnreadNotifications', async (req) => {
      const { recipientType, recipientID } = req.data;
      return await SELECT.from(Notifications).where({
        recipientType,
        recipientID,
        status: { '!=': 'Read' }
      });
    });

    this.on('getFailedNotifications', async (_req) => {
      return await SELECT.from(Notifications).where({ status: 'Failed' });
    });

    await super.init();
  }
};
