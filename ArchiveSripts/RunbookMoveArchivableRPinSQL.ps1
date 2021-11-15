#
# Copyright 2021 (c) Microsoft Corporation
#
# MIT License
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this script and associated documentation files (the "script"), to deal
# in the script without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the scipt, and to permit persons to whom the script is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the script.

# THE SCRIPT IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SCRIPT OR THE USE OR OTHER DEALINGS IN THE
# SCRIPT

<#
.SYNOPSIS
    Moves archivable RPs for a given SQL backup item
.DESCRIPTION
    Moves archivable RPs for a given SQL backup item to the VaultArchive tier. 
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
    
    [Parameter(Mandatory=$true, HelpMessage="Name of Virtual Machine")] 
    [String] $VMName,
    
    [Parameter(Mandatory=$true, HelpMessage="Name of DB")] 
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

$BackupItemList = Get-AzRecoveryServicesBackupItem -vaultId $vault.ID -BackupManagementType "AzureWorkload" -WorkloadType "MSSQL"
$bckItm = $BackupItemList | Where-Object {$_.FriendlyName -eq $DBName -and $_.ContainerName -match $VMName}
# for each sql item - move all move-ready recovery points (wihin given time range) to Archive
$EndDate1 = $EndDate
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

# for each sql item - move all move-ready recovery points (wihin given time range) to Archive
$result = @()
foreach ($rp in $allRecoveryPoints){
    $job = Move-AzRecoveryServicesBackupRecoveryPoint -RecoveryPoint $rp `
        -SourceTier $rp.RecoveryPointTier -DestinationTier VaultArchive -VaultId $vault.ID
    
    $result = $result + $job
}

Write-Output($result)
