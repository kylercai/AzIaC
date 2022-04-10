param(
     [Parameter()]
     [string]$SubscriptionID,
     [Parameter()]
     [string]$Location
 )

#$Environment = "AzureCloud"
$Environment = "AzureChinaCloud"

$K2Group = "K2GRP"

Connect-AzAccount -Environment  $Environment
#az cloud set -n $Environment
Set-AzContext -SubscriptionId $SubscriptionID 
az group create -g $K2Group -l $Location