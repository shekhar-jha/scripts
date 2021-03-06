# VMWare Scriptlets

## Install module

```powershell
Install-Module VMWare.PowerCLI -Scope CurrentUser
```

## VMWare Tools: Invoke scripts

The following code invokes script on machine to configure WinRM service for powershell remoting. This allows execution of various Windows Server operations remotely.

```powershell
Connect-VIServer '<ip address vmx console>'
$LocalIPAddress = '<IP address of client machine>'
$GuestCredential = Get-Credential
$VMNames = '<name of VM on VMWare>','<name of VM on VMWare';
foreach ($VMName in $VMNames)
{
    $VM = Get-VM -name $VMName;
    Invoke-VMScript -vm $VM -GuestCredential $GuestCredential -ScriptText "Enable-PSRemoting -Force;Set-Item WSMan:\localhost\Client\TrustedHosts -Concatenate -Value '$LocalIPAddress' -Force;Get-Item WSMan:\localhost\Client\TrustedHosts;winrm quickconfig -quiet;Restart-Service WinRM;" -ScriptType PowerShell
    Start-Process powershell -Verb runAs -ArgumentList "& '-Item -Concatenate -Value $VM.Guest.IPAddress'"
    Enter-PSSession -ComputerName "$($VM.Guest.IPAddress)" -Credential $GuestCredential
}
```
## Change Account details
```powershell
 $VM = Get-VM -name "Test Windows Server 4"; Invoke-VMScript -vm $VM -GuestCredential $GuestCredential -ScriptType PowerShell -ScriptText 'Set-LocalUser -Name "Administrator" -AccountNeverExpires:$true -PasswordNeverExpires:$true'
```
## Revert Snapshot

```powershell
$VMNames = '<name of VM on VMWare>','<name of VM on VMWare';
$SnapshotName = 'Base Install';
foreach ($VMName in $VMNames)
{
    $VM = Get-VM -name $VMName; 
    $shutdownStatus = Shutdown-VMGuest -VM $VM -Confirm:$false;
    Do { Start-Sleep -Seconds 5; $currentVMState =Get-VM $vmName; $status = $currentVMState.PowerState } Until ( $status -eq "PoweredOff"); 
    $Snap = Get-Snapshot -VM $VM -Name "$SnapshotName"; 
    $revertStatus = Set-VM -VM $VM -Snapshot $Snap -Confirm:$false;
    $startStatus = Start-VM -VM $VM
}
```

# Guest Windows Template

1. Disable Serial, Parallel Ports and Floppy controller in Bios
2. Install/Update VMWare Tools
3. License
4. Set Administrator Password
5. Date/Time Zone
6. Patch
7. Turn off system restore
8. Enable Remote access
9. System Settings -> Performance Best performance.
10 Startup and recovery-> Display list for 5 seconds
11. Power options-> Balanced -> Never
12. Personalization -> Turn off sound
13. Screen saver -> None
14. Taskbar -> Start Menu -> Power button -> Logoff
15. Enable Telent Client and disable other items in features : Media features, Print and Document Services, tablet pc components, XPS Services
16. Internet Explorer : About:blank
17. Disable Windows service : Windows Search; change registry in windows 10 to disable cloud search: 
    Windows Registry Editor Version 5.00
    [HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Search]
    "BingSearchEnabled"=dword:00000000
    "AllowSearchToUseLocation"=dword:00000000
    "CortanaConsent"=dword:00000000
    https://www.neowin.net/news/the-windows-10-spring-update-no-longer-lets-you-disable-web-search-in-start
18. System icon Volume, Action Center turn off
19. Always show all icons & notification in task bar
20. Depends on OS: Start menu -> Number of recent programs : 0 , in jump list: 0 , help uncheck. highlight newly installed program uncheck, use large icon: uncheck, documents,music, Pictures, personal folders, don't display; 
    display run ;     System admin tools: All prog & start menu; uncheck store & display recently opened programs & items.
21. taskbar buttons: Combine when taskbar is full.
22. Folder & Search options: always show icons never thumbnails, always show menus, fulll path, show hidden files, uncheck hide, >apply to all folders
23. Control panel - small icons
24. Control Panel > Sync Center > Manage offline files->General (Tab) > Disable offline files
25. Install/Update
    a. Notepad++
    b. Chrome/Edge
    c. bginfo --> Copy shortcut with following command to 
	    bginfo <file> /timer:0
    d. Uninstall onedrive
    
26. Copy the default profile by rebooting in safemode, login as third user, renaming "Default" folder and copying users directory to Default folder
    delete third user after setup.
27. Enable Administrator user id if disabled.
28. Needed if using old image: Fix Rearm issue on previous files: https://www.wintips.org/fix-sysprep-fatal-error-dwret-31-machine-invalid-state-couldnt-update-recorded-state/
    a. HKEY_LOCAL_MACHINE\System\Setup\Status\Sysprep Status - CleanupState 2, GeneralizationState 7
    b. HKEY_LOCAL_MACHINE\Software\Microsoft\WindowsNT\CurrentVersion\SoftwareProtectionPlatform --> SkipRearm 1
    c. admin cmd --> msdtc -uninstall; reboot; msdtc -install; reboot
29. Delete C:\Windows\System32\Sysprep\Panther
30 Cleanup C:\Windows\Temp\vmware-* (some files may fail);  C:\Windows\Temp\vmware-imc\*
31. Disable Hibernation(run cmd as administrator)
    powercfg.exe –h off
    bcdedit /timeout 5
32. cleanmgr.exe, cleanmgr /sageset:1
33. wevtutil el | Foreach-Object {wevtutil cl "$_"}
34. Control Panel->System->Advanced System Properties->performance->Advance->Virtual Memory->Change
    Uncheck “Automatically manage paging file size for all drives”
    Select “No paging file”
    Click “Set” to disable swap file
35. dfrgui.exe (only available on windows 7 and Thick provisioned drives)
36. Ensure that VM file size is packed
    a. Run sdelete -z C: on windows
    b. run cat /dev/zero > /big_zero ; sync; rm /big_zero
    c. shutdown the machine
    d. login to ESX server and run the command to thin and reduce size of the file.
       vmkfstools -K <file name>.vmdk
37. Start machine Enable paging files and shutdown
38. Change Disk to client and change network to generic location
39. Create template
