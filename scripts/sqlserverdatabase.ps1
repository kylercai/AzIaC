param(
     [Parameter()]
     [string]$SubscriptionID,
     [Parameter()]
     [string]$VMResourceGroupName,
     [Parameter()]
     [string]$VMName,
     [Parameter()]
     [string]$StorageResourceGroupName,
     [Parameter()]
     [string]$StorageAccountName,
     [Parameter()]
     [string]$ContainerName,
     [Parameter()]
     [string]$SqlServerInstance,
     [Parameter()]
     [string]$Database,
     [Parameter()]
     [string]$UserName,
     [Parameter()]
     [string]$Password,
     [Parameter()]
     [string]$Action
 )
#$PrefixName = 'k2sqlserverbackup' 
#$SubscriptionID = 'a15354eb-7827-4177-9745-7abe704ab8e9' 
#$StorageAccountName= $PrefixName + 'storage'
#$ContainerName= 'backup' 
#$Suffix = Get-Random -Maximum 10000
$PolicyName = $StorageAccountName + $Action + 'policy'
#$ResourceGroupName='K2-DB-Test'   
#$SqlServerInstance = "40.73.66.144"
#$Database = "K2"
#$UserName = "k2sqladmin"


Set-AzContext -SubscriptionId $SubscriptionID   

$AccountKeys = Get-AzStorageAccountKey -ResourceGroupName $StorageResourceGroupName -Name $StorageAccountName  

$StorageContext = New-AzStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $AccountKeys[0].Value
if ($Action -eq "backup")
{
    #Get-AzStorageBlob -Container $ContainerName -Context $StorageContext | Remove-AzStorageBlob
    #Remove-AzStorageBlob -Container $ContainerName -Context $StorageContext -Blob "$Database.bak" -ErrorAction SilentlyContinue
}
$Suffix = (Get-Date).ToString("yyyyMMddHHmmssFFFFFFF");
$BackupFileName = "fullbackup_$Database" + "_$Suffix.BAK"
if ($Action -eq "restore")
{
    $MaxReturn = 10000
    $Total = 0
    $Token = $Null
    $Prefix = "" + $Database
    $LastModified = Get-Date -Date "1900-01-01 00:00:00"
    do
    {
        $Blobs = Get-AzStorageBlob -Container $ContainerName -Prefix $Prefix -Context $StorageContext -MaxCount $MaxReturn  -ContinuationToken $Token #| Sort-Object @{expression="LastModified";Descending=$true}
        if($Blobs.Length -le 0) { Break;}
        else{
            #$LastModified.ToString("yyyy-MM-dd HH:mm:ss");
            #$Blobs[0].LastModified.ToString("yyyy-MM-dd HH:mm:ss");
            #$Blobs[0].Name
            foreach ($Blob in $Blobs) {
                if ($Blob.Name.ToLower().EndsWith(".bak") -and $Blob.LastModified -gt $LastModified)
                {
                    $BackupFileName = $Blob.Name
                    $LastModified = $Blob.LastModified
                    #$BackupFileName
                }
            }
            $Total += $Blobs.Count
        }
        $Token = $Blobs[$blobs.Count -1].ContinuationToken;
    }
    While ($null -ne $Token)
}
$BackupFileName

Remove-AzStorageContainerStoredAccessPolicy -Container $ContainerName -Policy $PolicyName -Context $StorageContext -ErrorAction SilentlyContinue
New-AzStorageContainerStoredAccessPolicy -Container $ContainerName -Policy $PolicyName -Context $StorageContext -StartTime $(Get-Date).ToUniversalTime().AddMinutes(-5) -ExpiryTime $(Get-Date).ToUniversalTime().AddYears(10) -Permission rwld


$SAS = New-AzStorageContainerSASToken -name $ContainerName -Policy $PolicyName -Context $StorageContext
#Write-Host 'Shared Access Signature= '$($SAS.Substring(1))''  

$Container = Get-AzStorageContainer -Context $StorageContext -Name $ContainerName
$CBC = $Container.CloudBlobContainer 

$Sql = "
IF EXISTS  (SELECT * FROM sys.credentials WHERE name = '{0}')
DROP CREDENTIAL [{0}]; 
CREATE CREDENTIAL [{0}] WITH IDENTITY='Shared Access Signature', SECRET='{1}'" -f $CBC.Uri,$SAS.Substring(1)  + ";" 

if ($Action -eq "backup")
{
    $Sql = $Sql + "
    BACKUP DATABASE K2   
    TO URL = 'https://" + $StorageAccountName + ".blob.core.chinacloudapi.cn/" + $ContainerName + "/" + $BackupFileName + "'
    WITH COMPRESSION, COPY_ONLY, STATS = 10;"
}
else 
{
    if($Action -eq "restore")
    {
        $Sql = $Sql + "
        RESTORE DATABASE K2   
        FROM URL = 'https://" + $StorageAccountName + ".blob.core.chinacloudapi.cn/" + $ContainerName + "/" + $BackupFileName + "'
        WITH REPLACE, STATS = 10;"
    }
}

$VM = Get-AzVM -ResourceGroupName $VMResourceGroupName -Name $VMName
$NI = Get-AzNetworkInterface | Where {$_.Id -eq $VM.NetworkProfile.NetworkInterfaces[0].Id}
$PUBIP = (Get-AzPublicIpAddress -Name $NI.IpConfigurations[0].PublicIpAddress.Id.Split('/')[-1] -ResourceGroupName $VMResourceGroupName).IpAddress


$ConnectionString = "Server=$PUBIP;database=master;Integrated Security=False;User ID=$UserName;Password=$Password;"
$SqlConnection = New-Object System.Data.SqlClient.SqlConnection $ConnectionString
$SqlConnection.Open()
$SqlCmd = New-Object System.Data.SqlClient.SqlCommand
$SqlCmd.CommandText = $Sql
$SqlCmd.Connection = $SqlConnection
$SqlCmd.CommandTimeout = 2*60*60
$SqlCmd.ExecuteNonQuery()
$SqlConnection.Close()