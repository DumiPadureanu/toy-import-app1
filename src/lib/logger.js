const cds = require('@sap/cds');

const LOG = cds.log('toyplatform');

/**
 * Centralized logging utility
 */
module.exports = {
  /**
   * Log informational message
   */
  info: (message, context = {}) => {
    LOG.info(message, context);
  },

  /**
   * Log warning message
   */
  warn: (message, context = {}) => {
    LOG.warn(message, context);
  },

  /**
   * Log error message
   */
  error: (message, error, context = {}) => {
    LOG.error(message, {
      ...context,
      error: error?.message || error,
      stack: error?.stack
    });
  },

  /**
   * Log debug message (only in development)
   */
  debug: (message, context = {}) => {
    if (process.env.NODE_ENV !== 'production') {
      LOG.debug(message, context);
    }
  }
};
