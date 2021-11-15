<#
.SYNOPSIS
    Moves recommended RPs for a given IaasVM
.DESCRIPTION
    Moves recommended RPs for a given IaasVM.
    This requires PowerShell 7.0 and Az.RecoveryServices preview module installed 
#>

param( 
    [Parameter(Mandatory=$true, HelpMessage="SubscriptionId or SubscriptionName ")] 
    [string] $Subscription, 

    [Parameter(Mandatory=$true)] 
    [string] $ResourceGroupName,

    [Parameter(Mandatory=$true)] 
    [string] $VaultName,
    
    [Parameter(Mandatory=$true, HelpMessage="Name of Backup Item")] 
    [String] $VMName
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
$vault =  Get-AzRecoveryServicesVault -ResourceGroupName $ResourceGroupName -Name $VaultName

$result = @()    

$BackupItemList = Get-AzRecoveryServicesBackupItem -vaultId $vault.ID -BackupManagementType "AzureVM" -WorkloadType "AzureVM"
$bckItm = $BackupItemList | Where-Object {$_.Name -match $VMName}

# for each vm item - move all recommended RPs to Archive
$recRPList = Get-AzRecoveryServicesBackupRecommendedArchivableRPGroup -Item $bckItm -VaultId $vault.ID

foreach ($rp in $recRPList){
    $job = Move-AzRecoveryServicesBackupRecoveryPoint -RecoveryPoint $rp `
    -SourceTier $rp.RecoveryPointTier -DestinationTier VaultArchive -VaultId $vault.ID

    $result = $result + $job
}

Write-Output($result)
