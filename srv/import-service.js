const cds = require('@sap/cds');
const { SELECT, INSERT, UPDATE } = cds.ql;

module.exports = class ImportService extends cds.ApplicationService {
  async init() {
    const { Shipments, ShipmentEvents } = this.entities;

    // CRUD handlers
    this.before('CREATE', Shipments, async (req) => {
      // Generate shipment number if not provided
      if (!req.data.shipmentNumber) {
        req.data.shipmentNumber = await this._generateShipmentNumber();
      }
      // Set default status
      if (!req.data.status) {
        req.data.status = 'PENDING';
      }
    });

    this.after('READ', Shipments, async (shipments, _req) => {
      // Enrich shipment data if needed
      if (Array.isArray(shipments)) {
        for (const shipment of shipments) {
          await this._enrichShipmentData(shipment);
        }
      } else if (shipments) {
        await this._enrichShipmentData(shipments);
      }
    });

    // Custom action handlers
    this.on('confirmShipmentArrival', async (req) => {
      const { shipmentID, actualArrivalDate } = req.data;
      
      const shipment = await SELECT.one.from(Shipments).where({ ID: shipmentID });
      if (!shipment) {
        req.reject(404, `Shipment ${shipmentID} not found`);
      }

      // Update shipment
      await UPDATE(Shipments).set({
        status: 'ARRIVED',
        actualArrival: actualArrivalDate,
        modifiedAt: new Date(),
        modifiedBy: req.user.id
      }).where({ ID: shipmentID });

      // Create arrival event
      await INSERT.into(ShipmentEvents).entries({
        shipment_ID: shipmentID,
        eventType: 'Arrival Confirmed',
        eventDate: new Date(),
        notes: `Shipment arrived on ${actualArrivalDate}`,
        recordedBy: req.user.id
      });

      // TODO: Trigger inventory update
      // TODO: Send notification

      return await SELECT.one.from(Shipments).where({ ID: shipmentID });
    });

    this.on('updateShipmentStatus', async (req) => {
      const { shipmentID, newStatus } = req.data;
      
      await UPDATE(Shipments).set({
        status: newStatus,
        modifiedAt: new Date(),
        modifiedBy: req.user.id
      }).where({ ID: shipmentID });

      // Log status change event
      await INSERT.into(ShipmentEvents).entries({
        shipment_ID: shipmentID,
        eventType: 'Status Change',
        eventDate: new Date(),
        notes: `Status changed to ${newStatus}`,
        recordedBy: req.user.id
      });

      return await SELECT.one.from(Shipments).where({ ID: shipmentID });
    });

    // Custom function handlers
    this.on('getShipmentsBySupplier', async (req) => {
      const { supplierID } = req.data;
      return await SELECT.from(Shipments).where({ supplier_ID: supplierID });
    });

    this.on('getOverdueShipments', async (_req) => {
      const today = new Date().toISOString().split('T')[0];
      return await SELECT.from(Shipments).where({
        status: { in: ['PENDING', 'IN_TRANSIT'] },
        expectedArrival: { '<': today }
      });
    });

    await super.init();
  }

  async _generateShipmentNumber() {
    const prefix = 'SH';
    const year = new Date().getFullYear().toString().slice(-2);
    const count = await SELECT.from(this.entities.Shipments).columns('count(*) as total');
    const sequence = (count[0].total + 1).toString().padStart(6, '0');
    return `${prefix}${year}${sequence}`;
  }

  async _enrichShipmentData(shipment) {
    // Calculate days in transit
    if (shipment.orderDate) {
      const endDate = shipment.actualArrival || new Date();
      const startDate = new Date(shipment.orderDate);
      shipment.daysInTransit = Math.floor((endDate - startDate) / (1000 * 60 * 60 * 24));
    }
  }
};
