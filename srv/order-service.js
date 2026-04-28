const cds = require('@sap/cds');

module.exports = class OrderService extends cds.ApplicationService {
  async init() {
    const { Orders, OrderItems, OrderNotes } = this.entities;

    this.before('CREATE', Orders, async (req) => {
      if (!req.data.orderNumber) {
        req.data.orderNumber = await this._generateOrderNumber();
      }
      req.data.orderDate = req.data.orderDate || new Date().toISOString().split('T')[0];
      req.data.status = req.data.status || 'PENDING';
    });

    this.on('confirmOrder', async (req) => {
      const { orderID } = req.data;
      await UPDATE(Orders).set({ status: 'CONFIRMED' }).where({ ID: orderID });
      // TODO: Reserve inventory, send notification
      return await SELECT.one.from(Orders).where({ ID: orderID });
    });

    this.on('cancelOrder', async (req) => {
      const { orderID, reason } = req.data;
      await UPDATE(Orders).set({ status: 'CANCELLED' }).where({ ID: orderID });
      await INSERT.into(OrderNotes).entries({
        order_ID: orderID,
        noteType: 'Cancellation',
        noteText: reason,
        isInternal: false
      });
      return await SELECT.one.from(Orders).where({ ID: orderID });
    });

    this.on('addOrderNote', async (req) => {
      const { orderID, noteText, isInternal } = req.data;
      const note = await INSERT.into(OrderNotes).entries({
        order_ID: orderID,
        noteType: 'General',
        noteText,
        isInternal
      });
      return note;
    });

    this.on('processPayment', async (req) => {
      const { orderID, paymentMethod, paymentReference } = req.data;
      await UPDATE(Orders).set({
        paymentStatus: 'Paid',
        paymentMethod,
        paymentDate: new Date().toISOString().split('T')[0]
      }).where({ ID: orderID });
      return await SELECT.one.from(Orders).where({ ID: orderID });
    });

    this.on('updateOrderStatus', async (req) => {
      const { orderID, newStatus } = req.data;
      await UPDATE(Orders).set({ status: newStatus }).where({ ID: orderID });
      return await SELECT.one.from(Orders).where({ ID: orderID });
    });

    this.on('getOrdersByCustomer', async (req) => {
      const { customerID } = req.data;
      return await SELECT.from(Orders).where({ customer_ID: customerID });
    });

    this.on('getOrdersByStatus', async (req) => {
      const { status } = req.data;
      return await SELECT.from(Orders).where({ status });
    });

    this.on('getOrdersByDateRange', async (req) => {
      const { startDate, endDate } = req.data;
      return await SELECT.from(Orders).where({ orderDate: { between: startDate, and: endDate } });
    });

    this.on('calculateOrderTotal', async (req) => {
      const { orderID } = req.data;
      const order = await SELECT.one.from(Orders).where({ ID: orderID });
      return order?.totalAmount || 0;
    });

    await super.init();
  }

  async _generateOrderNumber() {
    const prefix = 'ORD';
    const year = new Date().getFullYear().toString().slice(-2);
    const count = await SELECT.from(this.entities.Orders).columns('count(*) as total');
    const sequence = (count[0].total + 1).toString().padStart(6, '0');
    return `${prefix}${year}${sequence}`;
  }
};
