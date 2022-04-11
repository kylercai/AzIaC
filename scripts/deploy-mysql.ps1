param(
    [Parameter()]
    [string]$SubscriptionID,
    [Parameter()]
    [string]$Location,
    [Parameter()]
    [string]$K2Group
 )

$K2MySQLServer = "k2mysql01"

$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

.\mysqldeploy.ps1 -SubscriptionID $SubscriptionID -ResourceGroupName $K2Group -ServerName $K2MySQLServer -Location $Location -TemplateFile 'mysqltemplate.json' -TemplateParameterFile 'mysqlparameters.json'

# Calculate elapsed time
$stopwatch.Stop()
$stopwatch.Elapsed