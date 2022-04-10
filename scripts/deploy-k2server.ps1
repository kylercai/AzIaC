param(
      [Parameter()]
      [string]$K2Group,
      [Parameter()]
      [string]$Location
 )
 
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

#镜像：k2-eng-image-20220329192619
#/subscriptions/a15354eb-7827-4177-9745-7abe704ab8e9/resourceGroups/k2-aks/providers/Microsoft.Compute/images/k2-eng-image-20220329192619
az vm create  `
  -n 'k2-en-1'  `
  -g $K2Group  `
  --image 'k2-eng-image-20220329192619'  `
  --admin-username 'azureuser'  `
  --admin-password 'vanke@202203'  `
  --size Standard D8s_v4  `
  --vnet-name 'k2Vnet'  `
  --subnet 'k2WorkflowVMSubnet'  `
  -l $Location

# Calculate elapsed time
$stopwatch.Stop()
$stopwatch.Elapsed