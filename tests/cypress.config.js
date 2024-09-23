const { defineConfig } = require('cypress')


module.exports = defineConfig({
  e2e: {
    supportFile: 'cypress/support/e2e.{js,jsx,ts,tsx}',
    specPattern: 'cypress/e2e/**/*.cy.{js,jsx,ts,tsx}',
    baseUrl: 'http://127.0.0.1:8080',
  },
})