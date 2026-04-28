const cds = require('@sap/cds');
const { SELECT, INSERT } = cds.ql;

module.exports = class TrackingService extends cds.ApplicationService {
  async init() {
    const { Deliveries, DeliveryEvents, GeolocationPoints } = this.entities;

    this.on('updateLocation', async (req) => {
      const { deliveryID, latitude, longitude, accuracy, speed, heading } = req.data;
      
      const point = await INSERT.into(GeolocationPoints).entries({
        delivery_ID: deliveryID,
        timestamp: new Date(),
        latitude,
        longitude,
        accuracy,
        speed,
        heading
      });

      return point;
    });

    this.on('addTrackingEvent', async (req) => {
      const { deliveryID, eventType, eventTime, location, latitude, longitude, notes } = req.data;
      
      const event = await INSERT.into(DeliveryEvents).entries({
        delivery_ID: deliveryID,
        eventType,
        eventTime,
        location,
        latitude,
        longitude,
        notes
      });

      return event;
    });

    this.on('trackDelivery', async (req) => {
      const { trackingNumber } = req.data;
      
      const delivery = await SELECT.one.from(Deliveries).where({ trackingNumber });
      if (!delivery) {
        req.reject(404, 'Delivery not found');
      }

      const events = await SELECT.from(DeliveryEvents)
        .where({ delivery_ID: delivery.ID })
        .orderBy('eventTime desc');

      return {
        deliveryNumber: delivery.deliveryNumber,
        status: delivery.status,
        scheduledDate: delivery.scheduledDate,
        estimatedDelivery: delivery.estimatedDelivery,
        currentLocation: events[0]?.location || 'Unknown',
        events: events.map(e => ({
          eventType: e.eventType,
          eventTime: e.eventTime,
          location: e.location
        }))
      };
    });

    this.on('getDeliveryRoute', async (req) => {
      const { deliveryID } = req.data;
      
      const delivery = await SELECT.one.from(Deliveries).where({ ID: deliveryID });
      const points = await SELECT.from(GeolocationPoints)
        .where({ delivery_ID: deliveryID })
        .orderBy('timestamp');

      const currentLocation = points[points.length - 1] || null;

      return {
        deliveryNumber: delivery.deliveryNumber,
        origin: 'Warehouse', // TODO: Get from warehouse entity
        destination: delivery.deliveryAddress,
        currentLocation: currentLocation ? {
          latitude: currentLocation.latitude,
          longitude: currentLocation.longitude,
          timestamp: currentLocation.timestamp
        } : null,
        route: points.map(p => ({
          latitude: p.latitude,
          longitude: p.longitude,
          timestamp: p.timestamp
        }))
      };
    });

    this.on('getActiveDeliveriesMap', async (_req) => {
      const activeDeliveries = await SELECT.from(Deliveries).where({
        status: { in: ['IN_TRANSIT', 'OUT_FOR_DELIVERY'] }
      });

      const deliveriesWithLocation = [];
      
      for (const delivery of activeDeliveries) {
        const latestPoint = await SELECT.one.from(GeolocationPoints)
          .where({ delivery_ID: delivery.ID })
          .orderBy('timestamp desc');

        if (latestPoint) {
          deliveriesWithLocation.push({
            deliveryID: delivery.ID,
            deliveryNumber: delivery.deliveryNumber,
            status: delivery.status,
            latitude: latestPoint.latitude,
            longitude: latestPoint.longitude,
            lastUpdate: latestPoint.timestamp
          });
        }
      }

      return deliveriesWithLocation;
    });

    await super.init();
  }
};
