using { com.toyplatform.customers as customers } from '../db/customers';

/**
 * Customer Service - Manages customer profiles and contacts
 */
service CustomerService @(path: '/odata/v4/customer') {
  
  @odata.draft.enabled
  entity Customers as projection on customers.Customers;
  
  entity CustomerAddresses as projection on customers.CustomerAddresses;
  entity CustomerContacts as projection on customers.CustomerContacts;
  
  // Custom actions
  action activateCustomer(customerID : UUID) returns Customers;
  action deactivateCustomer(customerID : UUID, reason : String) returns Customers;
  action updateCreditLimit(customerID : UUID, newLimit : Decimal) returns Customers;
  
  // Address management
  action addAddress(
    customerID : UUID,
    addressType : String,
    street : String,
    city : String,
    state : String,
    postalCode : String,
    country : String
  ) returns CustomerAddresses;
  
  action setDefaultAddress(addressID : UUID) returns CustomerAddresses;
  
  // Contact management
  action addContact(
    customerID : UUID,
    firstName : String,
    lastName : String,
    email : String,
    phone : String,
    title : String
  ) returns CustomerContacts;
  
  // Custom functions
  function getCustomersByType(customerType : String) returns array of Customers;
  function getCustomerCreditStatus(customerID : UUID) returns {
    customerID : UUID;
    creditLimit : Decimal;
    creditUsed : Decimal;
    creditAvailable : Decimal;
  };
  function searchCustomers(searchTerm : String) returns array of Customers;
}
