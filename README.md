# Deploy bicep templates to Azure using GitHub Actions

- Create a resource group in azure (github-actions).
- Create a service principal in Azure and grant access to the aforementioned resource group. (az ad sp create-for-rbac --name "azureactions" --role contributor --scope /subscriptions/<Subscription-Id>/resourceGroups/<Resource-Group-Name>)
- Save the json response from the above step as an Action secret in Github. 
![github-action-secret](https://user-images.githubusercontent.com/25769615/195477028-1f3f3f20-9ed6-40a2-bedb-8ec8b694ca73.JPG)

- Configure the bicep templates.
- Updated Actions(main.ynl) file to connect to Azure and create the mentioned resources

# Resources created
![github-actions](https://user-images.githubusercontent.com/25769615/195476541-e606cff0-d9d4-480e-b68f-15f0748f8dae.JPG)
