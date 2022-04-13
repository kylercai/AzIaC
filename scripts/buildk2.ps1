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
$K2MySQLServer = "k2mysql01"
$MYSQLLocation = "chinaeast2"

$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

#Connect-AzAccount -Environment  $Environment
#az cloud set -n $Environment
# restore may needed
#Set-AzContext -SubscriptionId $SubscriptionID 
#az account set -s $SubscriptionID

az group create -l $Location -g $K2Group

#创建网络基础环境，创建AKS环境
./deploy-aks.ps1 -SubscriptionID $SubscriptionID -Location $Location -K2Group $K2Group

#恢复SQL Server数据库
./deploy-sqlserver.ps1 -SubscriptionID $SubscriptionID -Location $Location -K2Group $K2Group -K2BackupGroup $K2BackupGroup -K2BackupStorAcct $K2BackupStorAcct

#恢复MySQL数据库
./deploy-mysql.ps1 -SubscriptionID $SubscriptionID -Location $MYSQLLocation -K2MySQLServer $K2MySQLServer -K2Group $K2Group

#恢复K2服务器
./deploy-k2engine.ps1 -SubscriptionID $SubscriptionID -Location $Location -K2Group $K2Group -K2BackupGroup $K2BackupGroup

# Calculate elapsed time
$stopwatch.Stop()
$stopwatch.Elapsed