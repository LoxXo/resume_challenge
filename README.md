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
* Azure Functions API CI/CD gets Failure, but the Az resources are setup anyway

## Reflections on the project
1. Azure as a (free) cloud provider. AWS and GCP can also handle this project without any costs. [Extended opinion](#azure) 
2. Challenge of managing resource names. Specially anoying in case of Github Actions as their reusable workflows does not work when jobs include Bicep and/or multiple jobs and names can not be passed to further actions - [see extended](#github-actions). Can be done hardcoding names into deployment files, adding values via Github Secrets or by getting values via Azure CLI in every action.

## Extended thoughts
### Azure
Big share of corporate world in Europe. Nice support for the biggest partners. EntraID/AD that lets you control permissions in easy manner. User X always stays as user X, resource groups, easy to setup access to single resources.\
Decent UI, but good part of option's names doesn't translate to the ones in Bicep or AZ CLI. Overall clicking UI works well for Azure, but feels like underneath it lies mass of sewn together independed projects.\
C#, .Net is a Microsoft's baby and it shows. Function App documentation for Python can be out of date, basically there is no community support for it and it could be of a help as some stuff does not work as intendeed. Very good integration with VSCode.\
Azure Monitor is not free.

### Github Actions
help ***blinks 3 times***

[Jobs skips](https://github.com/actions/runner/issues/2205) - [More on it](https://github.com/orgs/community/discussions/45058)\
[Build Artifacts](https://github.com/actions/runner/issues/2205) - This one is affecting cypress tests if we would like to speed up multiple ones on a same build\
[Extra](https://github.com/Felixoid/actions-experiments/issues/9) - Some (not) so funny reported issues I found when troubleshooting\
[My favorite](https://github.com/actions/runner/issues/3266)\
[Problem that arrised from flexConsumption plan](https://github.com/Azure/functions-action/issues/273) and:

---
![alt text](https://i.imgur.com/cRBSfiG.jpeg "Example 1 error") \
![alt text](https://i.imgur.com/plyHpU7.png "Example 1 doc") \
![alt text](https://i.imgur.com/YNLa7Ij.jpeg "Example 1 doc")
---
![alt text](https://i.imgur.com/Tck5xl6.jpeg "Example 2 error") \
![alt text](https://i.imgur.com/y4iK8Ui.jpeg "Example 2 doc")
