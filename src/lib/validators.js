/**
 * Input validation utilities
 */

/**
 * Validate email format
 */
function isValidEmail(email) {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
}

/**
 * Validate phone number (basic)
 */
function isValidPhone(phone) {
  const phoneRegex = /^\+?[\d\s\-()]+$/;
  return phoneRegex.test(phone) && phone.length >= 10;
}

/**
 * Validate UUID format
 */
function isValidUUID(uuid) {
  const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
  return uuidRegex.test(uuid);
}

/**
 * Validate date string (YYYY-MM-DD)
 */
function isValidDate(dateString) {
  const date = new Date(dateString);
  return date instanceof Date && !isNaN(date) && dateString.match(/^\d{4}-\d{2}-\d{2}$/);
}

/**
 * Sanitize string input
 */
function sanitizeString(input) {
  if (typeof input !== 'string') return input;
  return input.trim().replace(/<script[^>]*>.*?<\/script>/gi, '');
}

/**
 * Validate required fields
 */
function validateRequired(data, requiredFields) {
  const missing = [];
  for (const field of requiredFields) {
    if (data[field] === undefined || data[field] === null || data[field] === '') {
      missing.push(field);
    }
  }
  return missing.length > 0 ? missing : null;
}

module.exports = {
  isValidEmail,
  isValidPhone,
  isValidUUID,
  isValidDate,
  sanitizeString,
  validateRequired
};
