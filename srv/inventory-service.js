const cds = require('@sap/cds');
const { SELECT, INSERT, UPDATE } = cds.ql;

module.exports = class InventoryService extends cds.ApplicationService {
  async init() {
    const { Products, InventoryLevels, StockMovements, StockAdjustments } = this.entities;

    // CRUD handlers
    this.before('CREATE', Products, async (req) => {
      // Generate SKU if not provided
      if (!req.data.sku) {
        req.data.sku = await this._generateSKU();
      }
    });

    this.after('READ', InventoryLevels, async (levels, _req) => {
      // Calculate available quantity
      if (Array.isArray(levels)) {
        for (const level of levels) {
          level.quantityAvailable = level.quantityOnHand - level.quantityReserved;
        }
      } else if (levels) {
        levels.quantityAvailable = levels.quantityOnHand - levels.quantityReserved;
      }
    });

    // Custom action: Adjust stock
    this.on('adjustStock', async (req) => {
      const { productID, warehouseID, quantity, reason } = req.data;

      // Get current level
      const level = await SELECT.one.from(InventoryLevels).where({
        product_ID: productID,
        warehouse_ID: warehouseID
      });

      if (!level) {
        req.reject(404, 'Inventory level not found');
      }

      const oldQuantity = level.quantityOnHand;
      const newQuantity = oldQuantity + quantity;

      // Update inventory level
      await UPDATE(InventoryLevels).set({
        quantityOnHand: newQuantity,
        quantityAvailable: newQuantity - level.quantityReserved,
        modifiedAt: new Date(),
        modifiedBy: req.user.id
      }).where({ ID: level.ID });

      // Record stock movement
      await INSERT.into(StockMovements).entries({
        product_ID: productID,
        warehouse_ID: warehouseID,
        movementType: 'ADJUSTMENT',
        quantity: quantity,
        movementDate: new Date(),
        notes: reason
      });

      // Record adjustment
      await INSERT.into(StockAdjustments).entries({
        product_ID: productID,
        warehouse_ID: warehouseID,
        quantityBefore: oldQuantity,
        quantityAfter: newQuantity,
        difference: quantity,
        reason: reason,
        adjustmentDate: new Date(),
        approvedBy: req.user.id
      });

      return await SELECT.one.from(InventoryLevels).where({ ID: level.ID });
    });

    // Custom action: Transfer stock
    this.on('transferStock', async (req) => {
      const { productID, fromWarehouseID, toWarehouseID, quantity } = req.data;

      // Validate source has enough stock
      const fromLevel = await SELECT.one.from(InventoryLevels).where({
        product_ID: productID,
        warehouse_ID: fromWarehouseID
      });

      if (!fromLevel || fromLevel.quantityAvailable < quantity) {
        req.reject(400, 'Insufficient stock for transfer');
      }

      // Deduct from source
      await UPDATE(InventoryLevels).set({
        quantityOnHand: fromLevel.quantityOnHand - quantity,
        quantityAvailable: fromLevel.quantityAvailable - quantity
      }).where({ ID: fromLevel.ID });

      // Add to destination
      const toLevel = await SELECT.one.from(InventoryLevels).where({
        product_ID: productID,
        warehouse_ID: toWarehouseID
      });

      if (toLevel) {
        await UPDATE(InventoryLevels).set({
          quantityOnHand: toLevel.quantityOnHand + quantity,
          quantityAvailable: toLevel.quantityAvailable + quantity
        }).where({ ID: toLevel.ID });
      } else {
        await INSERT.into(InventoryLevels).entries({
          product_ID: productID,
          warehouse_ID: toWarehouseID,
          quantityOnHand: quantity,
          quantityReserved: 0,
          quantityAvailable: quantity
        });
      }

      // Record movements
      await INSERT.into(StockMovements).entries([
        {
          product_ID: productID,
          warehouse_ID: fromWarehouseID,
          movementType: 'TRANSFER',
          quantity: -quantity,
          movementDate: new Date(),
          notes: `Transfer to warehouse ${toWarehouseID}`
        },
        {
          product_ID: productID,
          warehouse_ID: toWarehouseID,
          movementType: 'TRANSFER',
          quantity: quantity,
          movementDate: new Date(),
          notes: `Transfer from warehouse ${fromWarehouseID}`
        }
      ]);

      return true;
    });

    // Custom action: Reserve stock
    this.on('reserveStock', async (req) => {
      const { productID, warehouseID, quantity } = req.data;

      const level = await SELECT.one.from(InventoryLevels).where({
        product_ID: productID,
        warehouse_ID: warehouseID
      });

      if (!level || level.quantityAvailable < quantity) {
        return false;
      }

      await UPDATE(InventoryLevels).set({
        quantityReserved: level.quantityReserved + quantity,
        quantityAvailable: level.quantityAvailable - quantity
      }).where({ ID: level.ID });

      return true;
    });

    // Custom action: Release stock
    this.on('releaseStock', async (req) => {
      const { productID, warehouseID, quantity } = req.data;

      const level = await SELECT.one.from(InventoryLevels).where({
        product_ID: productID,
        warehouse_ID: warehouseID
      });

      if (!level) {
        return false;
      }

      await UPDATE(InventoryLevels).set({
        quantityReserved: Math.max(0, level.quantityReserved - quantity),
        quantityAvailable: level.quantityAvailable + quantity
      }).where({ ID: level.ID });

      return true;
    });

    // Custom function: Get low stock products
    this.on('getLowStockProducts', async (req) => {
      const { warehouseID } = req.data;

      const query = SELECT.from(Products, p => {
        p`.*`;
        p.inventoryLevels(l => {
          l.quantityAvailable;
          l.quantityOnHand;
        }).where({ warehouse_ID: warehouseID });
      }).where`exists inventoryLevels[quantityAvailable <= reorderLevel]`;

      return await cds.run(query);
    });

    // Custom function: Get product availability
    this.on('getProductAvailability', async (req) => {
      const { productID } = req.data;

      const levels = await SELECT.from(InventoryLevels).where({ product_ID: productID });

      const totalAvailable = levels.reduce((sum, l) => sum + l.quantityAvailable, 0);

      const warehouseBreakdown = levels.map(l => ({
        warehouseID: l.warehouse_ID,
        warehouseName: l.warehouse?.name || 'Unknown',
        available: l.quantityAvailable
      }));

      return {
        productID,
        totalAvailable,
        warehouseBreakdown
      };
    });

    await super.init();
  }

  async _generateSKU() {
    const prefix = 'TOY';
    const count = await SELECT.from(this.entities.Products).columns('count(*) as total');
    const sequence = (count[0].total + 1).toString().padStart(6, '0');
    return `${prefix}${sequence}`;
  }
};
