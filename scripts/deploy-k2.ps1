$Group = "k2-aks"
$k2DeploymentName = "k2-deploy"

$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
az deployment group create `
  --name $k2DeploymentName `
  --resource-group $Group `
  --template-file ../main.bicep `
  --parameters ../azuredeploy.parameters.json

# Calculate elapsed time
$stopwatch.Stop()
$stopwatch.Elapsed