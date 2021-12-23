Different modules sometimes with overlapping capabilities are available from Microsoft for managing Azure capabilities. This tries to collect some of these scenarios for reference.

# Install Modules

## Az

Used to manage Azure subscription and services related use-cases. Limited capability for Azure AD.

```poweshell
Install-Module Az
```

## Azure AD V2 | MSOnline

Provides wrapper over MS Graph API. MSOnline is an older version using V1 Graph API and Azure AD uses the new API.

**TODO:** 

1. Need to understand relevance over MS Graph module
2. Feature comparison between Azure AD V2 & MSOnline.

```poweshell
Install-Module AzureAD
Install-Module MSOnline
```
**OR**
```poweshell
Install-Module AzureADPreview
Install-Module MSOnline
```

## MS Graph

Wrapper over graph API. Run the second line below to select beta profile.

```poweshell
Install-Module Microsoft.Graph
Install-module Microsoft.Graph.Identity.Signins
Select-MgProfile -Name beta
```

## M365 Components

```poweshell
Install-Module -Name ExchangeOnlineManagement
Install-Module -Name Microsoft.Online.SharePoint.PowerShell
Install-Module -Name MicrosoftTeams
```

# Pre-req 

Before running any command, you may have to execute the following command

```poweshell
Set-ExecutionPolicy RemoteSigned
```

# Connect

Authenticate once and then session is cached.

## Az

This uses browser popup to authenticate user and capture token for future calls. Seems to be active till powershell is exited.

```poweshell
Connect-AzAccount
```

## Azure AD V2 | MSOnline

```
$AzureAdCred = Get-Credential
Connect-AzureAD -Credential $AzureAdCred
```
**OR**

```poweshell
$Msolcred = Get-credential
Connect-MsolService -Credential $MsolCred
```

## MS Graph

Delegated access uses device flow to authenticate user and getting the token for specific scopes. This token is persisted for the PS session.

```poweshell
Connect-MgGraph -Scopes UserAuthenticationMethod.ReadWrite.All
```

# Get User details

## Az

There is no API available to retrieve all users with all details.

###  Azure AD V2 | MSOnline 

```poweshell
$users = Get-AzureADUser -All $true
$users | forEach-Object {$_|select ObjectId, Mobile}| ConvertTo-Csv
```

## MS Graph

```poweshell
$user=Get-MgUser -All
$users | forEach-Object {$_|select Id, MobilePhone}| ConvertTo-Csv
```

# Powershell Module management

## Updates

```poweshell
Update-Module
```

## Uninstall
Powershell modules uninstallation must be done one module at a time. Use following scipt for cleanups

```poweshell
Uninstall-Module <Microsoft.Graph|Az>
Get-InstalledModule <Microsoft.Graph.*|Az.*> | %{ if($_.Name -ne "Microsoft.Graph.Authentication"){ Uninstall-Module $_.Name } }
Uninstall-Module Microsoft.Graph.Authentication
```

# Sensitivity Labels

## Enable sensitivity labels

[Create and configure sensitivity labels](https://docs.microsoft.com/en-us/microsoft-365/compliance/create-sensitivity-labels?view=o365-worldwide#create-and-configure-sensitivity-labels) and then [publish](https://docs.microsoft.com/en-us/microsoft-365/compliance/create-sensitivity-labels?view=o365-worldwide#publish-sensitivity-labels-by-creating-a-label-policy) them and sync the labels with Azure AD

```powershell
Execute-AzureAdLabelSync
```

## Enable sensitivity labels for groups

[Enabling Group Sensitivity Level](https://docs.microsoft.com/en-us/azure/active-directory/enterprise-users/groups-assign-sensitivity-labels?WT.mc_id=Portal-Microsoft_AAD_IAM) 


```powershell
Connect-AzureAD
$grpUnifiedSetting = (Get-AzureADDirectorySetting | where -Property DisplayName -Value "Group.Unified" -EQ)
$template = Get-AzureADDirectorySettingTemplate -Id 62375ab9-6b52-47ed-826b-58e47e0e304b
$setting = $template.CreateDirectorySetting()
$Setting["EnableMIPLabels"] = "True"
# if running for the first time.
# New-AzureADDirectorySetting -DirectorySetting $Setting
# If running new
# Set-AzureADDirectorySetting -Id $grpUnifiedSetting.Id -DirectorySetting $setting
```

