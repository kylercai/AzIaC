param(
     [Parameter()]
     [string]$SubscriptionID,
     [Parameter()]
     [string]$LocationName,
     [Parameter()]
     [string]$StorageResourceGroupName,
     [Parameter()]
     [string]$StorageAccountName,
     [Parameter()]
     [string]$ContainerName
 ) 
#$prefixName = 'k2sqlserverbackup' 
#$subscriptionID = 'a15354eb-7827-4177-9745-7abe704ab8e9' 
#$locationName = 'China East 2' 
#$storageAccountName= $prefixName + 'storage'
#$containerName= 'backup' 
#$resourceGroupName='K2-DB-Test'   

#Set-AzContext -SubscriptionId $SubscriptionID   

New-AzStorageAccount -Name $StorageAccountName -ResourceGroupName $StorageResourceGroupName -Type Standard_RAGRS -Location $LocationName   

$AccountKeys = Get-AzStorageAccountKey -ResourceGroupName $StorageResourceGroupName -Name $StorageAccountName  

do{
    $Failed = $false
    Try{
        $StorageContext = New-AzStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $AccountKeys[0].Value
        $Container = New-AzStorageContainer -Context $StorageContext -Name $ContainerName
        Write-Host "DONE"
    } catch 
    { 
        $Failed = $true 
        Start-Sleep -s 15
        Write-Host "Retry..."
    }
} while ($Failed)
