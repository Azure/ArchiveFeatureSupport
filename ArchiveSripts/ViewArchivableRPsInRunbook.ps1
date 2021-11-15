<#
.SYNOPSIS
    View Archivable Recovery Points
.DESCRIPTION
    View Archivable Recovery Points.
    By default this script list RPs for last 2 years.
    This requires PowerShell 7.0 and Az.RecoveryServices preview module installed 
#>

param( 
    [Parameter(Mandatory=$true)] 
    [string] $Subscription,

    [Parameter(Mandatory=$true)] 
    [string] $ResourceGroupName,

    [Parameter(Mandatory=$true)] 
    [string] $VaultName,

    [Parameter(Mandatory=$true, HelpMessage="Valid values: AzureVM, MSSQL")] 
    [string] $ItemType,

    [Parameter(Mandatory=$false, HelpMessage="Start Date in Utc")] 
    [System.DateTime] $StartDate = (Get-Date).AddDays(-730).ToUniversalTime(),

    [Parameter(Mandatory=$false, HelpMessage="End Date in Utc")] 
    [System.DateTime] $EndDate = (Get-Date).AddDays(0).ToUniversalTime(),
    
    [Parameter(Mandatory=$true, HelpMessage="Name of Virtual Machine")] 
    [String] $VMName,

    [Parameter(Mandatory=$false, HelpMessage="Name of DB Item")] 
    [String] $DBName

)

function script:TraceMessage([string] $message, [string] $color="Yellow")
{
    Write-Host "`n$message" -ForegroundColor $color
}

$connection = Get-AutomationConnection -Name AzureRunAsConnection

$connectionResult = Connect-AzAccount `
-ServicePrincipal `
-Subscription $Subscription `
-Tenant $connection.TenantID `
-ApplicationId $connection.ApplicationID `
-CertificateThumbprint $connection.CertificateThumbprint
"Login successful.."

try
{
    Set-AzContext -Subscription $Subscription | Out-Null
}
catch
{
    Add-AzAccount
    Set-AzContext -Subscription $Subscription | Out-Null
}

#fetch recovery services vault  
$vault =  Get-AzRecoveryServicesVault -ResourceGroupName $ResourceGroupName -Name $VaultName

# Command Output 
    
if($ItemType -eq "AzureVM"){
    # for vm item - move all recommended RPs to Archive    
    $EndDate1 = $EndDate    
    $BackupItemList = Get-AzRecoveryServicesBackupItem -vaultId $vault.ID -BackupManagementType "AzureVM" -WorkloadType "AzureVM"
    $bckItm = $BackupItemList | Where-Object {$_.Name -match $VMName}        
    while ($EndDate1 -ge $StartDate) {
        $timeDiff = ($EndDate1 - $StartDate)
    
        if($timeDiff.Days -ge 30){
            $StartDate1 = $EndDate1.AddDays(-30).ToUniversalTime()
        }
        else {
            $StartDate1 = $StartDate
        }

        $archivableVMRPs = Get-AzRecoveryServicesBackupRecoveryPoint -Item $bckItm `
        -StartDate $StartDate1 -EndDate $EndDate1 -VaultId $vault.ID -IsReadyForMove $true `
        -TargetTier VaultArchive

        $allRecoveryPoints = $allRecoveryPoints + $archivableVMRPs                       

        $EndDate1 = $EndDate1.AddDays(-30).ToUniversalTime() 
    } 
}
elseif ($ItemType -eq "MSSQL") {    
    # for sql item - move all move-ready recovery points (wihin given time range) to Archive
    $EndDate1 = $EndDate
    $BackupItemList = Get-AzRecoveryServicesBackupItem -vaultId $vault.ID -BackupManagementType "AzureWorkload" -WorkloadType "MSSQL"
    $bckItm = $BackupItemList | Where-Object {$_.Name -match $DBName -and $_.ContainerName -match $VMName}
    while ($EndDate1 -ge $StartDate) {
        $timeDiff = ($EndDate1 - $StartDate)
    
        if($timeDiff.Days -ge 30){
            $StartDate1 = $EndDate1.AddDays(-30).ToUniversalTime()
        }
        else {
            $StartDate1 = $StartDate
        }

        $archivableSQLRPs = Get-AzRecoveryServicesBackupRecoveryPoint -Item $bckItm `
        -StartDate $StartDate1 -EndDate $EndDate1 -VaultId $vault.ID -IsReadyForMove $true `
        -TargetTier VaultArchive
        
        $allRecoveryPoints = $allRecoveryPoints + $archivableSQLRPs 
        
        $EndDate1 = $EndDate1.AddDays(-30).ToUniversalTime() 
    }                         
}
else {
    Write-Error "Invalid ItemType. Valid values: AzureVM, MSSQL"
}

Write-Output ($allRecoveryPoints)
