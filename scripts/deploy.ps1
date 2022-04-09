param(
     [Parameter()]
     [string]$SubscriptionID
 )

#$SubscriptionID = "3dde1082-e5c1-4d68-8832-28fdd5a7452c"
$Environment = "AzureChinaCloud"
$Location = "chinaeast2"
$K2Group = "K2RG"
$K2BackupGroup = "K2BackupRG"
$K2BackupStorAcctName = "K2BackupStorAcct"

Connect-AzAccount -Environment  $Environment
#az cloud set -n $Environment
Set-AzContext -SubscriptionId $SubscriptionID 

#创建网络基础环境，创建AKS环境
./deploy-aks.ps1 -Location $Location -K2Group $K2Group

#恢复SQL Server数据库
#./deploy-sqlserver.ps1 -SubscriptionID $SubscriptionID -Location $Location -K2RGName $K2Group -K2BackupRGName $K2BacGroupame -K2BackupStorAcctName $K2BackupStorAcctName

#恢复MySQL数据库

#恢复K2服务器
#./deploy-k2.ps1 -Location $Location -K2RGName $K2Group