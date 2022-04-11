param(
     [Parameter()]
     [string]$SubscriptionID,
     [Parameter()]
     [string]$VMName,
     [Parameter()]
     [string]$VMResourceGroupName,
     [Parameter()]
     [string]$StorageAccountName,
     [Parameter()]
     [string]$StorageResourceGroupName
 )
# restore may needed
Set-AzContext -SubscriptionId $SubscriptionID   

#$VMName = "k2sqlserver01"
#$ResourceGroupName = "K2-DB-Test"
#$StorageAccountName = "k2sqlserverbackupstorage"
#$StorageResourceGroupName = $StorageResourceGroupName
$RetentionPeriod = 30
$BackupScheduleType = "Manual"
$FullBackupFrequency = "Daily"
$FullBackupStartHour = "20"
$FullBackupWindow = "2"
$LogBackupFrequency = "60"

$Storage = Get-AzStorageAccount -ResourceGroupName $StorageResourceGroupName `
    -Name $StorageAccountName -ErrorAction SilentlyContinue

$AutoBackupConfig = New-AzVMSqlServerAutoBackupConfig -Enable `
    -RetentionPeriodInDays $RetentionPeriod -StorageContext $Storage.Context `
    -ResourceGroupName $StorageResourceGroupName -BackupSystemDbs `
    -BackupScheduleType $BackupScheduleType -FullBackupFrequency $FullBackupFrequency `
    -FullBackupStartHour $FullBackupStartHour -FullBackupWindowInHours $FullBackupWindow `
    -LogBackupFrequencyInMinutes $LogBackupFrequency

# Apply the Automated Backup settings to the VM

Set-AzVMSqlServerExtension -AutoBackupSettings $AutoBackupConfig `
    -VMName $VMName -ResourceGroupName $VMResourceGroupName