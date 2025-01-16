describe('The Resume Page', () => {
  it('Loads the webpage with text content and failed visitcounter.js', () => {
    cy.log('URL env value:', Cypress.env('url'))
    // cy.intercept({method:'GET', url:'func-http-trigger-resume.azurewebsites.net/api/new_visitor'},
    // req => {req.destroy()})
    cy.visit('http://172.28.48.1:8080') // change URL to match your dev URL
    cy.get('[data-cy="visitors"').should('have.text', 'Error')
    cy.get('[data-cy="name"]').should('have.text', 'Jakub Wajda')
    cy.get('[data-cy="head_work"]').should('have.text', 'WORK EXPERIENCE')
    cy.get('[data-cy="first_job_record"]').should('have.text', 'Fujitsu02.2023 - current')
  })
  it('Images are visible', () => {
    cy.visit('http://172.28.48.1:8080')
    cy.get('[data-cy="github_logo"]')
    .should('be.visible')
    .and(($img) => {
      expect($img[0].naturalWidth).to.be.greaterThan(0)
    })
  })
  it('API is returning the data', () => {
    cy.visit('http://172.28.48.1:8080')
    cy.intercept('GET', 'func-http-trigger-resume.azurewebsites.net/api/new_visitor?').as('getVisitor')
    cy.wait('@getVisitor').then((interception) => {
    assert.isNotNull(interception.response.body, 'API call has returned no data')
    })
})
})