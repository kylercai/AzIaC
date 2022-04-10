param(
    [Parameter()]
    [string]$SubscriptionID,
    [Parameter()]
    [string]$Location,
    [Parameter()]
    [string]$K2Group,
    [Parameter()]
    [string]$K2BackupGroup,
    [Parameter()]
    [string]$K2BackupStorAcct
 )

#$SQLVMName = 'k2sqlserver01'
#$SQLVMPipName = $SQLVMName+"-ip"

$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

#az network public-ip create -g $K2Group -n $SQLVMPipName -l $Location --sku Basic --allocation-method static
#$SQLVMPip = az network public-ip show -n k2sqlserver01-ip -g k2-aks --query ipAddress

#部署sql server
.\sqlserverdeploy.ps1 -SubscriptionID $SubscriptionID -VnetName 'k2Vnet' -SubnetName 'k2WorkflowSQLVMSubnet' -VnetResourceGroupName $K2Group -Location $Location -VMResourceGroupName $K2Group -VMName 'k2sqlserver01' -TemplateFile 'sqlservertemplate.json' -TemplateParameterFile 'sqlserverparameters.json'

#部署自动备份策略，备份设置为依然保存在之前的存储上：$K2BackupGroup/k2sqlserverbackupstorage
.\sqlautobackup.ps1 -SubscriptionID $SubscriptionID -VMName 'k2sqlserver01' -StorageAccountName $K2BackupStorAcct -VMResourceGroupName $K2Group -StorageResourceGroupName $K2BackupGroup

#将数据库还原到新实例VM
.\sqlserverdatabase.ps1 -SubscriptionID $SubscriptionID -VMResourceGroupName $K2Group -StorageResourceGroupName $K2BackupGroup -StorageAccountName $K2BackupStorAcct -ContainerName 'backupcontainer' -VMName 'k2sqlserver01' -Database K2 -UserName k2sqladmin -Password k2dbP@ssw0rd+2022 -Action restore

# Calculate elapsed time
$stopwatch.Stop()
$stopwatch.Elapsed