# Azure Cloud Resume Challenge

## Too long; didn't read
The final result of my approach to the [Cloud Resume Challenge](https://cloudresumechallenge.dev/) is this very repository and my website: https://jwajda.com.
* HTML and CSS for website hosted in Azure Static Web Apps
* API in Python as Azure Functions
* NoSQL CosmosDB database to hold the data
* Javascript to request the API and display the response on the webpage
* Smoke testing with Cypress to check if webpage content loads and API is accesible
* Deployment is written in Bicep
* CI/CD is done in GitHub Actions

## Reflections on the project
1. Azure as a (free) cloud provider. AWS and GCP can also handle this project without any costs. [Extended opinion](#azure) 
2. ...


## Extended thoughts
### Azure
Big share of corporate world in Europe. Nice support for the biggest partners. EntraID/AD that lets you control permissions in easy manner. User X always stays as user X, resource groups, easy to setup access to single resources.\
Decent UI, but good part of option's names doesn't translate to the ones in Bicep or AZ CLI. Overall clicking UI works well for Azure, but feels like underneath it lies mass of sewn together independed projects.\
C#, .Net is a Microsoft's baby and it shows. Function App documentation for Python can be out of date, basically there is no community support for it and it could be of a help as some stuff does not work as intendeed. Very good integration with VSCode.\
Azure Monitor is not free.
### 
...
