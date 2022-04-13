param(
      [Parameter()]
      [string]$SubscriptionID,
      [Parameter()]
      [string]$Location,
      [Parameter()]
      [string]$K2Group
 )

$aksDeploymnetName = "aks-deploy"

$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

#Set-AzContext -SubscriptionId $SubscriptionID

$Path = (Get-Item .).FullName
$TemplateParameterFile = "azuredeploy.parameters.json"
$TemplateParameterFileText = [System.IO.File]::ReadAllText($Path + "\" + $TemplateParameterFile)
$TemplateParameterObject = ConvertFrom-Json $TemplateParameterFileText
$TemplateParameterObject.parameters.location.value = $Location
$TemplateParameterFile = $Path + "\" + $TemplateParameterFile
$TemplateParameterObject | ConvertTo-Json -depth 100 | Set-Content $TemplateParameterFile

$TemplateMainFile = $Path + "\" + "main.bicep"

az deployment group create  `
  --template-file $TemplateMainFile `
  --parameters $TemplateParameterFile `
  --resource-group $K2Group `
  --name $aksDeploymnetName

# Calculate elapsed time
$stopwatch.Stop()
$stopwatch.Elapsed