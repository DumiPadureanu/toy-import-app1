const cds = require('@sap/cds');

module.exports = class CustomerService extends cds.ApplicationService {
  async init() {
    const { Customers, CustomerAddresses, CustomerContacts } = this.entities;

    this.before('CREATE', Customers, async (req) => {
      if (!req.data.customerNumber) {
        req.data.customerNumber = await this._generateCustomerNumber();
      }
    });

    this.on('activateCustomer', async (req) => {
      const { customerID } = req.data;
      await UPDATE(Customers).set({ isActive: true }).where({ ID: customerID });
      return await SELECT.one.from(Customers).where({ ID: customerID });
    });

    this.on('deactivateCustomer', async (req) => {
      const { customerID, reason } = req.data;
      await UPDATE(Customers).set({ isActive: false, notes: reason }).where({ ID: customerID });
      return await SELECT.one.from(Customers).where({ ID: customerID });
    });

    this.on('updateCreditLimit', async (req) => {
      const { customerID, newLimit } = req.data;
      await UPDATE(Customers).set({ creditLimit: newLimit }).where({ ID: customerID });
      return await SELECT.one.from(Customers).where({ ID: customerID });
    });

    this.on('addAddress', async (req) => {
      const { customerID, addressType, street, city, state, postalCode, country } = req.data;
      const address = await INSERT.into(CustomerAddresses).entries({
        customer_ID: customerID,
        addressType,
        street,
        city,
        state,
        postalCode,
        country
      });
      return address;
    });

    this.on('setDefaultAddress', async (req) => {
      const { addressID } = req.data;
      const address = await SELECT.one.from(CustomerAddresses).where({ ID: addressID });
      await UPDATE(CustomerAddresses).set({ isDefault: false }).where({ customer_ID: address.customer_ID });
      await UPDATE(CustomerAddresses).set({ isDefault: true }).where({ ID: addressID });
      return await SELECT.one.from(CustomerAddresses).where({ ID: addressID });
    });

    this.on('addContact', async (req) => {
      const { customerID, firstName, lastName, email, phone, title } = req.data;
      const contact = await INSERT.into(CustomerContacts).entries({
        customer_ID: customerID,
        firstName,
        lastName,
        email,
        phone,
        title
      });
      return contact;
    });

    this.on('getCustomersByType', async (req) => {
      const { customerType } = req.data;
      return await SELECT.from(Customers).where({ customerType });
    });

    this.on('getCustomerCreditStatus', async (req) => {
      const { customerID } = req.data;
      const customer = await SELECT.one.from(Customers).where({ ID: customerID });
      return {
        customerID,
        creditLimit: customer.creditLimit || 0,
        creditUsed: customer.creditUsed || 0,
        creditAvailable: (customer.creditLimit || 0) - (customer.creditUsed || 0)
      };
    });

    this.on('searchCustomers', async (req) => {
      const { searchTerm } = req.data;
      return await SELECT.from(Customers).where`name like ${`%${searchTerm}%`} or customerNumber like ${`%${searchTerm}%`}`;
    });

    await super.init();
  }

  async _generateCustomerNumber() {
    const prefix = 'CUST';
    const count = await SELECT.from(this.entities.Customers).columns('count(*) as total');
    const sequence = (count[0].total + 1).toString().padStart(6, '0');
    return `${prefix}${sequence}`;
  }
};
