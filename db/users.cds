namespace com.toyplatform.users;

using { cuid, managed } from '@sap/cds/common';
using { com.toyplatform.Status as Status } from './common';

/**
 * Users - system users
 */
entity Users : cuid, managed {
  username       : String(255) not null;
  email          : String(255) not null;
  
  firstName      : String(100);
  lastName       : String(100);
  
  // Authentication (password stored separately in XSUAA)
  lastLogin      : DateTime;
  loginCount     : Integer default 0;
  
  // Profile
  phone          : String(50);
  department     : String(100);
  jobTitle       : String(100);
  
  // Status
  status         : Status default 'ACTIVE';
  isLocked       : Boolean default false;
  lockReason     : String(255);
  
  // Associations
  roles          : Association to many UserRoles on roles.user = $self;
  auditLogs      : Association to many AuditLogs on auditLogs.user = $self;
}

/**
 * Roles - system roles for RBAC
 */
entity Roles : cuid, managed {
  code           : String(50) not null;
  name           : String(255) not null;
  description    : LargeString;
  
  isSystem       : Boolean default false; // System roles cannot be deleted
  isActive       : Boolean default true;
  
  // Associations
  users          : Association to many UserRoles on users.role = $self;
}

/**
 * User Roles - many-to-many mapping between users and roles
 */
entity UserRoles : cuid, managed {
  user           : Association to Users not null;
  role           : Association to Roles not null;
  
  assignedDate   : Date;
  expiryDate     : Date;
  assignedBy     : String(255);
}

/**
 * Audit Logs - system audit trail
 */
entity AuditLogs : cuid {
  user           : Association to Users;
  
  timestamp      : DateTime not null;
  action         : String(100) not null; // e.g., "CREATE", "UPDATE", "DELETE", "LOGIN"
  entityType     : String(100); // e.g., "Order", "Shipment"
  entityID       : UUID;
  
  changesBefore  : LargeString; // JSON
  changesAfter   : LargeString; // JSON
  
  ipAddress      : String(50);
  userAgent      : String(500);
  
  notes          : LargeString;
}
