module.exports = {
  testEnvironment: 'node',
  coverageDirectory: 'coverage',
  collectCoverageFrom: [
    'srv/**/*.js',
    'src/**/*.js',
    '!**/node_modules/**',
    '!**/gen/**',
  ],
  testMatch: [
    '**/test/**/*.test.js',
  ],
  coverageThreshold: {
    global: {
      branches: 70,
      functions: 70,
      lines: 70,
      statements: 70,
    },
  },
};
