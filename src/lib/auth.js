/**
 * Authentication and authorization helpers
 * Placeholder for XSUAA integration
 */

/**
 * Check if user has specific role
 */
function hasRole(req, role) {
  return req.user?.is(role) || false;
}

/**
 * Check if user has any of the specified roles
 */
function hasAnyRole(req, roles) {
  return roles.some(role => hasRole(req, role));
}

/**
 * Check if user has all specified roles
 */
function hasAllRoles(req, roles) {
  return roles.every(role => hasRole(req, role));
}

/**
 * Get current user ID
 */
function getUserId(req) {
  return req.user?.id || 'anonymous';
}

/**
 * Get current user name
 */
function getUserName(req) {
  return req.user?.name || 'Anonymous';
}

/**
 * Require authentication middleware
 */
function requireAuth(req) {
  if (!req.user || req.user.id === 'anonymous') {
    req.reject(401, 'Authentication required');
  }
}

/**
 * Require specific role middleware
 */
function requireRole(req, role) {
  requireAuth(req);
  if (!hasRole(req, role)) {
    req.reject(403, `Role ${role} required`);
  }
}

module.exports = {
  hasRole,
  hasAnyRole,
  hasAllRoles,
  getUserId,
  getUserName,
  requireAuth,
  requireRole
};
