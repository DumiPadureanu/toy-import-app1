const cds = require('@sap/cds');

// Custom server configuration (if needed)
cds.on('bootstrap', app => {
  // Add custom middleware here if needed
  app.use((req, res, next) => {
    res.setHeader('X-Content-Type-Options', 'nosniff');
    res.setHeader('X-Frame-Options', 'DENY');
    res.setHeader('X-XSS-Protection', '1; mode=block');
    next();
  });
});

module.exports = cds.server;
