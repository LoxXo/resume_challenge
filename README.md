# Azure Cloud Resume Challenge

## Deployment
### Manual steps needed
1. [Create Application Object](https://learn.microsoft.com/en-us/entra/identity-platform/quickstart-register-app)
2. [Create GH Actions Secret](https://learn.microsoft.com/en-us/azure/developer/github/connect-from-azure-secret):

AZURE_CREDENTIALS 

3. Create role in subscription. It is standard Contributor role but with additional privilege:
* Microsoft.Authorization/roleAssignments/write
* Microsoft.Authorization/roleAssignments/delete
```az role definition create --role-definition az_roles/contributor_resume.json```

4. Create Service Principal with role newly created role:
```az ad sp create-for-rbac --name {applicationId} --role "Contributor Role Assigner" --scopes subscriptions/{subscriptionId}```

5. Deploy code starting 'Deploy Bicep file' workflow. 

6. [Setup external Custom domain in Static Web App](https://learn.microsoft.com/en-us/azure/static-web-apps/custom-domain-external)

## Too long; didn't read
The final result of my approach to the [Cloud Resume Challenge](https://cloudresumechallenge.dev/) is this very repository and my website: https://jwajda.com.
* HTML and CSS for website hosted in Azure Static Web Apps
* API in Python as Azure Functions
* NoSQL CosmosDB database to hold the data
* Javascript to request the API and display the response on the webpage
* Smoke testing with Cypress to check if webpage content loads and API is accesible
* Deployment is written in Bicep
* CI/CD is done in GitHub Actions
* Azure Functions API CI/CD gets Failure, but the Az resources are setup anyway