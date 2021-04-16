Different modules sometimes with overlapping capabilities are available from Microsoft for managing Azure capabilities. This tries to collect some of these scenarios for reference.

# Install

## Az

Used to manage Azure subscription and services related use-cases. Limited capability for Azure AD.

```
Install-Module Az
```

## Azure AD V2 | MSOnline

Provides wrapper over MS Graph API. MSOnline is an older version using V1 Graph API and Azure AD uses the new API.

**TODO:** 

1. Need to understand relevance over MS Graph module
2. Feature comparison between Azure AD V2 & MSOnline.

```
Install-Module AzureAD
Install-module AzureADPreview
```
**OR**
```
Install-Module MSOnline
```

## MS Graph

Wrapper over graph API. Run the second line below to select beta profile.

```
Install-module Microsoft.Graph.Identity.Signins
Select-MgProfile -Name beta
```


# Connect

Authenticate once and then session is cached.

## Az

This uses browser popup to authenticate user and capture token for future calls. Seems to be active till powershell is exited.

```
Connect-AzAccount
```

## Azure AD V2 | MSOnline

```
$AzureAdCred = Get-Credential
Connect-AzureAD -Credential $AzureAdCred
```
**OR**

```
$Msolcred = Get-credential
Connect-MsolService -Credential $MsolCred
```

## MS Graph

Delegated access uses device flow to authenticate user and getting the token for specific scopes. This token is persisted for the PS session.

```
Connect-MgGraph -Scopes UserAuthenticationMethod.ReadWrite.All
```

# Get User details

## Az

There is no API available to retrieve all users with all details.

###  Azure AD V2 | MSOnline 

```
$users = Get-AzureADUser -All $true
$users | forEach-Object {$_|select ObjectId, Mobile}| ConvertTo-Csv
```

## MS Graph

```
$user=Get-MgUser -All
$users | forEach-Object {$_|select Id, MobilePhone}| ConvertTo-Csv
```

# Powershell uninstall

Powershell modules uninstallation must be done one module at a time. Use following scipt for cleanups

```
Uninstall-Module <Microsoft.Graph|Az>
Get-InstalledModule <Microsoft.Graph.*|Az.*> | %{ if($_.Name -ne "Microsoft.Graph.Authentication"){ Uninstall-Module $_.Name } }
Uninstall-Module Microsoft.Graph.Authentication
```
