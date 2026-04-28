const cds = require('@sap/cds');

module.exports = class DeliveryService extends cds.ApplicationService {
  async init() {
    const { Deliveries, DeliveryEvents, DeliveryRoutes, GeolocationPoints } = this.entities;

    this.before('CREATE', Deliveries, async (req) => {
      if (!req.data.deliveryNumber) {
        req.data.deliveryNumber = await this._generateDeliveryNumber();
      }
      req.data.status = req.data.status || 'SCHEDULED';
    });

    this.on('scheduleDelivery', async (req) => {
      const { orderID, warehouseID, carrierID, scheduledDate } = req.data;
      const delivery = await INSERT.into(Deliveries).entries({
        order_ID: orderID,
        warehouse_ID: warehouseID,
        carrier_ID: carrierID,
        scheduledDate,
        status: 'SCHEDULED'
      });
      return delivery;
    });

    this.on('updateDeliveryStatus', async (req) => {
      const { deliveryID, newStatus } = req.data;
      await UPDATE(Deliveries).set({ status: newStatus }).where({ ID: deliveryID });
      await INSERT.into(DeliveryEvents).entries({
        delivery_ID: deliveryID,
        eventType: 'Status Change',
        eventTime: new Date(),
        notes: `Status changed to ${newStatus}`
      });
      return await SELECT.one.from(Deliveries).where({ ID: deliveryID });
    });

    this.on('recordProofOfDelivery', async (req) => {
      const { deliveryID, signatureUrl, photoUrl, receiverName } = req.data;
      await UPDATE(Deliveries).set({
        status: 'DELIVERED',
        signatureUrl,
        photoUrl,
        deliveredToName: receiverName,
        actualDelivery: new Date()
      }).where({ ID: deliveryID });
      return await SELECT.one.from(Deliveries).where({ ID: deliveryID });
    });

    this.on('trackLocation', async (req) => {
      const { deliveryID, latitude, longitude } = req.data;
      const point = await INSERT.into(GeolocationPoints).entries({
        delivery_ID: deliveryID,
        timestamp: new Date(),
        latitude,
        longitude,
        accuracy: 10
      });
      return point;
    });

    this.on('createRoute', async (req) => {
      const { routeDate, driver, vehicle } = req.data;
      const routeNumber = await this._generateRouteNumber();
      const route = await INSERT.into(DeliveryRoutes).entries({
        routeNumber,
        routeDate,
        driver,
        vehicle,
        status: 'Planned'
      });
      return route;
    });

    this.on('addDeliveryToRoute', async (req) => {
      const { routeID, deliveryID, sequenceNumber } = req.data;
      await UPDATE(Deliveries).set({
        route_ID: routeID,
        stopNumber: sequenceNumber
      }).where({ ID: deliveryID });
      return true;
    });

    this.on('optimizeRoute', async (req) => {
      const { routeID } = req.data;
      // TODO: Implement route optimization algorithm
      return await SELECT.one.from(DeliveryRoutes).where({ ID: routeID });
    });

    this.on('getDeliveriesByRoute', async (req) => {
      const { routeID } = req.data;
      return await SELECT.from(Deliveries).where({ route_ID: routeID });
    });

    this.on('getActiveDeliveries', async (req) => {
      return await SELECT.from(Deliveries).where({
        status: { in: ['SCHEDULED', 'PICKED_UP', 'IN_TRANSIT', 'OUT_FOR_DELIVERY'] }
      });
    });

    this.on('getDeliveryHistory', async (req) => {
      const { deliveryID } = req.data;
      return await SELECT.from(DeliveryEvents).where({ delivery_ID: deliveryID }).orderBy('eventTime');
    });

    this.on('estimateDeliveryTime', async (req) => {
      const { deliveryID } = req.data;
      // TODO: Implement delivery time estimation
      const delivery = await SELECT.one.from(Deliveries).where({ ID: deliveryID });
      return delivery?.estimatedDelivery;
    });

    await super.init();
  }

  async _generateDeliveryNumber() {
    const prefix = 'DEL';
    const year = new Date().getFullYear().toString().slice(-2);
    const count = await SELECT.from(this.entities.Deliveries).columns('count(*) as total');
    const sequence = (count[0].total + 1).toString().padStart(6, '0');
    return `${prefix}${year}${sequence}`;
  }

  async _generateRouteNumber() {
    const prefix = 'RT';
    const date = new Date().toISOString().split('T')[0].replace(/-/g, '');
    const count = await SELECT.from(this.entities.DeliveryRoutes).columns('count(*) as total');
    const sequence = (count[0].total + 1).toString().padStart(3, '0');
    return `${prefix}${date}${sequence}`;
  }
};
