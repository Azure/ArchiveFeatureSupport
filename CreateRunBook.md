---
page_type: sample
languages:
- powershell
products:
- azure
description: "Automates top asks using PowerShell for Azure Backup archive feature"
---

# Automate top asks using PowerShell Scripts in an Azure Automation Runbook

## Features
Runbooks for Archive move

## Sample Scripts 

1. Create an [Automation Account](https://ms.portal.azure.com/#blade/HubsExtension/BrowseResource/resourceType/Microsoft.Automation%2FAutomationAccounts) in Azure Portal
2. Import Az.RecoveryServices 4.0.0-preview module from [Powershell Gallery](https://www.powershellgallery.com/packages/Az.RecoveryServices/4.0.0-preview)
       
       a. Select the required module.
       
       b. Deploy to Azure Automation and select the Automation account and resource group.
3. Click on Runbooks in Policy Automation from the automation account.
4. Import a runbook.
5. To create the runbook - download the scripts and then import them to your runbook.

 
## View Archivable Points 

### Location

Download [viewArchivableRPs](https://github.com/hiaga/Az.RecoveryServices/blob/master/ArchiveFeatureSupport/ViewArchivableRPsInRunbook.ps1)

### Purpose 

This sample script is used to view all the archivable recovery points associated with a backup item between any time range. 

You can link the runbook to a scheduler.

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
 

## Move all Archivable recovery point for a SQL Server in Azure VM 

### Location 
Download [moveArchivableRecoveryPointsForSQL](https://github.com/hiaga/Az.RecoveryServices/blob/master/ArchiveFeatureSupport/RunbookMoveArchivableRPinSQL.ps1)

### Purpose

This sample script moves all the archivable recovery point for a particular SQL Backup Item to archive. 
 
You can link the runbook to a scheduler.

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
  

## Move all recommended recovery points to archive for a Virtual Machine workload 

### Location 

Download [moveRecommendedRPsForIaasVM](https://github.com/hiaga/Az.RecoveryServices/blob/master/ArchiveFeatureSupport/MoveRecommendedRPsForVMinRunbook.ps1)


### Purpose

Move all the recommended recovery points to archive for a particular Virtual Machine workload. 

You can link the runbook to a scheduler.

### Input Parameters 

1. Subscription 
2. ResourceGroupName 
3. VaultName 
4. VMName


### Output 

A list of move jobs initiated for each recovery point being moved to archive 
 
