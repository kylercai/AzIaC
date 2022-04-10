param(
      [Parameter()]
      [string]$SubscriptionID,
      [Parameter()]
      [string]$VnetName,
      [Parameter()]
      [string]$SubnetName,
      [Parameter()]
      [string]$VnetResourceGroupName,
      [Parameter()]
      [string]$Location,
      [Parameter()]
      [string]$VMResourceGroupName,
      [Parameter()]
      [string]$VMName,
      [Parameter()]
      [string]$TemplateFile,
      [Parameter()]
      [string]$TemplateParameterFile
 )

Set-AzContext -SubscriptionId $SubscriptionID   #"a15354eb-7827-4177-9745-7abe704ab8e9"

#$VnetName = "k2Vnet"
#$VnetResourceGroupName = "k2-aks"
#$VMName = "k2sqlserver01"
$Path = (Get-Item .).FullName

$Suffix = Get-Random -Maximum 1000

$TemplateParameterFileText = [System.IO.File]::ReadAllText($Path + "\" + $TemplateParameterFile)
$TemplateParameterObject = ConvertFrom-Json $TemplateParameterFileText

$TemplateParameterObject.parameters.networkInterfaceName.value = $VMName + $Suffix
$TemplateParameterObject.parameters.location.value = $Location
$TemplateParameterObject.parameters.virtualMachineRG.value = $VMResourceGroupName
$TemplateParameterObject.parameters.virtualMachineName.value = $VMName
$TemplateParameterObject.parameters.virtualMachineComputerName.value = $VMName
$TemplateParameterObject.parameters.sqlVirtualMachineName.value = $VMName
#$TemplateParameterObject.parameters.virtualNetworkId.value = "/subscriptions/" + $SubscriptionID + "/resourceGroups/" + $VnetResourceGroupName + "/providers/Microsoft.Network/virtualNetworks/k2Vnet"
$TemplateParameterObject.parameters.dataDisks.value[0].name = $VMName + "_DataDisk_0"
$TemplateParameterObject.parameters.dataDiskResources.value[0].name = $VMName + "_DataDisk_0"

$VNet = Get-AzVirtualNetwork -Name $VnetName -ResourceGroupName $VnetResourceGroupName
$TemplateParameterObject.parameters.virtualNetworkId.value = $VNet.Id
$TemplateParameterObject.parameters.subnetName.value = $SubnetName
$TemplateParameterObject.parameters.publicIpAddressName.value = $VMName + "-ip"

$TemplateFile = $Path + "\" + $TemplateFile
$TemplateParameterFile = $Path + "\" + $VMName + "_" + $TemplateParameterFile
$TemplateParameterObject | ConvertTo-Json -depth 100 | Set-Content $TemplateParameterFile
New-AzResourceGroupDeployment -Name $VMName -ResourceGroupName $VMResourceGroupName -TemplateFile $TemplateFile -TemplateParameterFile $TemplateParameterFile

