param(
      [Parameter()]
      [string]$SubscriptionID,
      [Parameter()]
      [string]$Location,
      [Parameter()]
      [string]$K2Group,
      [Parameter()]
      [string]$K2BackupGroup
 )
 
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

#Set-AzContext -SubscriptionId $SubscriptionID

#镜像：k2-eng-image-20220329192619
#/subscriptions/<subscription_id>/resourceGroups/K2Backup/providers/Microsoft.Compute/images/k2-eng-image-20220329192619

#$ImageId = Get-AzResource -ResourceGroup $K2BackupGroup -Name k2-eng-image-20220329192619 -ResourceType Microsoft.Compute/images | Select-Object -expand ResourceId

#Image Galleries
#/subscriptions/<subscription_id>/resourceGroups/K2Backup/providers/Microsoft.Compute/galleries/k2_eng_image/images/k2_eng_image
$ImageId = Get-AzResource -ResourceGroup $K2BackupGroup -Name k2_eng_image/k2_eng_image -ResourceType Microsoft.Compute/galleries/images | Select-Object -expand ResourceId

az vm create  `
  -n 'k2-en-1'  `
  -g $K2Group  `
  --image $ImageId  `
  --admin-username 'azureuser'  `
  --admin-password 'vanke@202203'  `
  --size Standard_D8s_v4  `
  --vnet-name 'k2Vnet'  `
  --subnet 'k2WorkflowVMSubnet'  `
  -l $Location

# Calculate elapsed time
$stopwatch.Stop()
$stopwatch.Elapsed