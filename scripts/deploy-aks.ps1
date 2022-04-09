param(
      [Parameter()]
      [string]$Location,
      [Parameter()]
      [string]$K2Group
 )

$aksDeploymnetName = "aks-deploy"

$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

az group create -l $Location -g $K2Group

az deployment group create  `
  --template-file ../main.bicep `
  --parameters ../azuredeploy.parameters.json `
  --resource-group $K2Group `
  --name $aksDeploymnetName

# Calculate elapsed time
$stopwatch.Stop()
$stopwatch.Elapsed