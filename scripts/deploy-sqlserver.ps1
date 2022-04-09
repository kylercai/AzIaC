param(
    [Parameter()]
    [string]$SubscriptionID,
    [Parameter()]
    [string]$Location,
    [Parameter()]
    [string]$Location,
    [Parameter()]
    [string]$Group
 )

$SQLVMName = 'k2sqlserver01'
$SQLVMPipName = $SQLVMName+"-ip"

$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

az network public-ip create -g $Group -n $SQLVMPipName -l $Location --sku Basic --allocation-method static
$SQLVMPip = az network public-ip show -n k2sqlserver01-ip -g k2-aks --query ipAddress

#部署sql server
.\db\sqlserverdeploy.ps1 -SubscriptionID $SubscriptionID -VnetName 'k2Vnet' -SubnetName 'k2WorkflowSQLVMSubnet' -VnetResourceGroupName $Group -Location $Location -VMResourceGroupName 'K2-DB-Test' -VMName 'k2sqlserver01' -VMPipName $SQLVMPipName -TemplateFile 'sqlservertemplate.json' -TemplateParameterFile 'sqlserverparameters.json'

#将数据库还原到新实例
.\db\sqlserverdatabase.ps1 -SubscriptionID $SubscriptionID -ResourceGroupName K2-DB-Test -StorageAccountName k2sqlserverbackupstorage -ContainerName backupcontainer -SqlServerInstance $SQLVMPip -Database K2 -UserName k2sqladmin -Password k2dbP@ssw0rd+2022 -Action restore

#部署用于备份的存储
.\db\storage.ps1 -SubscriptionID $SubscriptionID -LocationName 'China East 2' -ResourceGroupName K2-DB-Test -StorageAccountName k2sqlserverbackupstorage -ContainerName backup

#部署自动备份策略
.\db\sqlautobackup.ps1 -SubscriptionID $SubscriptionID -VMName k2sqlserver01 -StorageAccountName k2sqlserverbackupstorage -StorageResourceGroupName K2-DB-Test

# Calculate elapsed time
$stopwatch.Stop()
$stopwatch.Elapsed