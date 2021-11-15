<#
.SYNOPSIS
    Moves archivable RPs for a given SQL Server
.DESCRIPTION
    Moves archivable RPs for a given SQL Server to the VaultArchive tier. 
    By default this script moves archivable RPs for last 2 years.
    This requires PowerShell 7.0 and Az.RecoveryServices preview module installed 
#>

param( 
    [Parameter(Mandatory=$true)] 
    [string] $Subscription,

    [Parameter(Mandatory=$true)] 
    [string] $ResourceGroupName,

    [Parameter(Mandatory=$true)] 
    [string] $VaultName,

    [Parameter(Mandatory=$false, HelpMessage="Start Date in Utc")] 
    [System.DateTime] $StartDate = (Get-Date).AddDays(-730).ToUniversalTime(),

    [Parameter(Mandatory=$false, HelpMessage="End Date in Utc")] 
    [System.DateTime] $EndDate = (Get-Date).AddDays(0).ToUniversalTime(),
    
    [Parameter(Mandatory=$true, HelpMessage="Name of SQL Server")] 
    [String] $ServerName
    
)

function script:TraceMessage([string] $message, [string] $color="Yellow")
{
    Write-Host "`n$message" -ForegroundColor $color
}

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
$result = @()
$vault =  Get-AzRecoveryServicesVault -ResourceGroupName $ResourceGroupName -Name $VaultName

$BackupItemList = Get-AzRecoveryServicesBackupItem -vaultId $vault.ID -BackupManagementType "AzureWorkload" -WorkloadType "MSSQL"
$bckItm = $BackupItemList | Where-Object {$_.ServerName -eq $ServerName}

# for each sql item - move all move-ready recovery points (wihin given time range) to Archive
foreach ($item in $bckItm){
    $archivableSQLRPs = Get-AzRecoveryServicesBackupRecoveryPoint -Item $item -StartDate $StartDate -EndDate $EndDate -VaultId $vault.ID -IsReadyForMove $true -TargetTier VaultArchive

    if(!($null -eq $archivableSQLRPs)){
        
        foreach ($rp in $archivableSQLRPs){
            $job = Move-AzRecoveryServicesBackupRecoveryPoint -RecoveryPoint $rp `
                -SourceTier VaultStandard -DestinationTier VaultArchive -VaultId $vault.ID
                            
            $result = $result + $job
        }
        
          
    }
}

Write-Output($result)
