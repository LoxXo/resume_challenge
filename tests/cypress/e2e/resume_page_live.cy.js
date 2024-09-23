describe('The Resume Page', () => {
  it('successfully loads', () => {
    cy.intercept({method:'GET', url:'https://http-trigger-cosmos-resume.azurewebsites.net/api/new_visitor'},
    req => {req.destroy()})
    cy.visit('/') // change URL to match your dev URL
    cy.get('[data-cy="visitors-js"').should('have.text', 'Error')
    cy.get('[data-cy="name"]').should('have.text', 'Jakub Wajda')
    cy.get('[data-cy="head_work"]').should('have.text', 'WORK EXPERIENCE')
    cy.get('[data-cy="first_record"]').should('have.text', 'Fujitsu02.2023 - current')
    cy.intercept('GET', 'https://http-trigger-cosmos-resume.azurewebsites.net/api/new_visitor?').as('getVisitor')
    //cy.wait('@getVisitor')
    cy.wait('@getVisitor').then((interception) => {
    assert.isNotNull(interception.response.body, 'API call has data')
    cy.get('[data-cy="github_logo"]')
    .should('be.visible')
    .and(($img) => {
    expect($img[0].naturalWidth).to.be.greaterThan(0)
    })
    })
  })
})