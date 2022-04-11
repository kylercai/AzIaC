param(
    [Parameter()]
    [string]$SubscriptionID,
    [Parameter()]
    [string]$ResourceGroupName,
    [Parameter()]
    [string]$ServerName,
    [Parameter()]
    [string]$Location,
    [Parameter()]
    [string]$TemplateFile,
    [Parameter()]
    [string]$TemplateParameterFile
 )

# restore may needed
Set-AzContext -SubscriptionId $SubscriptionID

$Path = (Get-Item .).FullName
$Suffix = Get-Random -Maximum 1000
$Date = Get-Date
$DateSuffix = $Date.ToString("yyyyMMddTHHmmssfffffffZ")

$TemplateParameterFileText = [System.IO.File]::ReadAllText($Path + "\" + $TemplateParameterFile)
$TemplateParameterFileText = $TemplateParameterFileText.replace('[ServerName]', $ServerName).replace('[DateSuffix]', $DateSuffix)
$TemplateParameterObject = ConvertFrom-Json $TemplateParameterFileText
$TemplateParameterObject.parameters.location.value = $Location


$TemplateFile = $Path + "\" + $TemplateFile
$TemplateParameterFile = $Path + "\" + $ServerName + "_" + $TemplateParameterFile
$TemplateParameterObject | ConvertTo-Json -depth 100 | Set-Content $TemplateParameterFile

New-AzResourceGroupDeployment -Name $ServerName -ResourceGroupName $ResourceGroupName `
  -TemplateFile $TemplateFile `
  -TemplateParameterFile $TemplateParameterFile
