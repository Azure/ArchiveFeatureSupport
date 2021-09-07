---
page_type: sample
languages:
- powershell
products:
- azure
description: "Automates top asks using PowerShell for Azure Backup archive feature"
---

# Automate top asks using PowerShell for Azure Backup

Automate archive move using [PowerShell for Azure Backup](https://docs.microsoft.com/en-us/azure/backup/archive-tier-support#get-started-with-powershell)

## Features
Runbooks for Archive move

## Sample Scripts 

1. Run Latest Version of [Powershell](https://github.com/PowerShell/PowerShell/releases/download/v7.1.3/PowerShell-7.1.3-win-x64.msi) in administrator mode 

2. Run the following command to set the execution policy (this allows permission for scripts to be run)

        Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process 

3. Download the scripts

4. Use the following commands for installation and setup

        cd <Location of the script> 

        install-module -name Az.RecoveryServices -Repository PSGallery -AllowClobber -Force

5. Connect to Azure using the "Connect-AzAccount" cmdlet.
       
6. Run the scripts
 
 
## View Archivable Points 

### Location

Download [viewArchivableRPs](https://github.com/hiaga/Az.RecoveryServices/blob/master/ArchiveFeatureSupport/viewArchivableRPs.ps1)

### Purpose 

This sample script is used to view all the archivable recovery points associated with a backup item between any time range. 

### Input Parameters  

1. Subscription 
2. ResourceGroupName 
3. VaultName 
4. ItemType – {AzureVM,MSSQL) 
5. StartDate = (Get-Date).AddDays(-x).ToUniversalTime()  
6. EndDate = (Get-Date).AddDays(-y).ToUniversalTime() 
7. VMName
8. DBName(Only for SQL DB)  

Where x and y are the time-range between which you want to move the recovery points. 


### Output 

A list of archivable recovery point 
 

### Example Usage 

$ArchivableRecoveryPoints = .\viewArchivableRPs.ps1 -Subscription xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx -ResourceGroupName "ResourceGroupName" -VaultName "VaultName" -ItemType "MSSQL/AzureVM" -VMName "VMName" -DBName "DBName" -StartDate (Get-Date).AddDays(-165).ToUniversalTime() -EndDate (Get-date).AddDays(0).ToUniversalTime() 


## Move all Archivable recovery point for a SQL Server in Azure VM 

### Location 
Download [moveArchivableRecoveryPointsForSQL](https://github.com/hiaga/Az.RecoveryServices/blob/master/ArchiveFeatureSupport/moveArchivableRecoveryPointsForSQL.ps1)

### Purpose

This sample script moves all the archivable recovery point for a particular SQL Backup Item to archive. 
 

### Input Parameters 

1. Subscription 
2. ResourceGroupName 
3. VaultName 
4. VMName
5. DBName
6. StartDate (Get-Date).AddDays(-x).ToUniversalTime() 
7. EndDate (Get-date).AddDays(-y).ToUniversalTime() 

Where x and y are the time-range between which you want to move the recovery points. 

 
### Output 

A list of move jobs initiated for each recovery point being moved to archive. 
 

### Example Usage 

$MoveJobsSQL = .\moveArchivableRecoveryPointsForSQL.ps1 -Subscription xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx -ResourceGroupName "ResourceGroupName" -VaultName "VaultName" -VMName "VMName" -DBName "DBName" -StartDate (Get-Date).AddDays(-165).ToUniversalTime() -EndDate (Get-date).AddDays(0).ToUniversalTime() 


## Move all Archivable recovery point for all the databases for a particular SQL Server in Azure VM 

### Location 
Download [moveArchivableRecoveryPointsForSQLServer](https://github.com/hiaga/Az.RecoveryServices/blob/master/ArchiveFeatureSupport/moveArchivableRecoveryPointsForSQLServer.ps1)

### Purpose

This sample script moves all the archivable recovery point for all the databases for a SQLServer to archive. 
 

### Input Parameters 

1. Subscription 
2. ResourceGroupName 
3. VaultName 
4. ServerName
5. StartDate (Get-Date).AddDays(-x).ToUniversalTime() 
6. EndDate (Get-date).AddDays(-y).ToUniversalTime() 

Where x and y are the time-range between which you want to move the recovery points. 

 
### Output 

A list of move jobs initiated for each recovery point being moved to archive. 
 

### Example Usage 

$MoveJobsSQL = .\moveArchivableRecoveryPointsForSQLServer.ps1 -Subscription xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx -ResourceGroupName "ResourceGroupName" -VaultName "VaultName" -ServerName "ServerName" -StartDate (Get-Date).AddDays(-165).ToUniversalTime() -EndDate (Get-date).AddDays(0).ToUniversalTime() 
 

## Move all recommended recovery points to archive for a Virtual Machine workload 

### Location 

Download [moveRecommendedRPsForIaasVM](https://github.com/hiaga/Az.RecoveryServices/blob/master/ArchiveFeatureSupport/moveRecommendedRPsForIaasVM.ps1)


### Purpose

Move all the recommended recovery points to archive for a particular Virtual Machine workload. 

### Input Parameters 

1. Subscription 
2. ResourceGroupName 
3. VaultName 
4. VMName


### Output 

A list of move jobs initiated for each recovery point being moved to archive 

### Example Usage 

$MoveJobsIaasVM = .\moveRecommendedRPsForIaasVM.ps1 -Subscription xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx -ResourceGroupName "ResourceGroupName" -VaultName "VaultName" -VMName "VMName"
