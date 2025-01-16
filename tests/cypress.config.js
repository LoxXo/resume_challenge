const { defineConfig } = require('cypress')


module.exports = defineConfig({
  e2e: {
    supportFile: 'cypress/support/e2e.{js,jsx,ts,tsx}',
    specPattern: 'cypress/e2e/**/*.cy.{js,jsx,ts,tsx}',
    setupNodeEvents(on, config) {
      on("task", {
        log(args) {
          console.log(...args);
          return null;
        },
      })}}})