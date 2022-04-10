param(
     [Parameter()]
     [string]$SubscriptionID,
     [Parameter()]
     [string]$Location
 )

#$Environment = "AzureCloud"
$Environment = "AzureChinaCloud"

$K2Group = "K2IaC"
$K2BackupGroup = "K2Backup"
$K2BackupStorAcct = "k2sqlserverbackupstorage"

Connect-AzAccount -Environment  $Environment
#az cloud set -n $Environment
Set-AzContext -SubscriptionId $SubscriptionID 

#创建网络基础环境，创建AKS环境
./deploy-aks.ps1 -Location $Location -K2Group $K2Group

#恢复SQL Server数据库
./deploy-sqlserver.ps1 -SubscriptionID $SubscriptionID -Location $Location -K2Group $K2Group -K2BackupGroup $K2BackupGroup -K2BackupStorAcct $K2BackupStorAcct

#恢复MySQL数据库

#恢复K2服务器
./deploy-k2server.ps1 -Location $Location -K2Group $K2Group -K2BackupGroup $K2BackupGroup