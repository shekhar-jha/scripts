Steps to integrate Linux with AD for authentication.

1. DNS Setup
Ensure that you are able to connect to AD Server
```
ping -c2 dc01.addomain.acme.org
```
2. Time syncing setup
```
sudo apt-get install ntpdate
sudo ntpdate -q dc01.addomain.acme.org
sudo ntpdate dc01.addomain.acme.org
```
3. Install the required packages
```
sudo apt install krb5-user samba sssd chrony
```
   a. During kerberos installation, provide the default realm
```
ADDOMAIN.ACME.ORG
```
4. Verify the kerberos setup
```
kinit <user id>
klist
```
5. Configure the Kerberos by providing the following /etc/krb5.conf under section as identified
```
[libdefaults]
 ticket_lifetime = 24h #
 renew_lifetime = 7d
 dns_lookup_realm = false
 forwardable = true
 rdns = false
 default_ccache_name = KEYRING:persistent:%{uid}
 
[realms]
 ADDOMAIN.ACME.ORG = {
 }
 
[domain_realm]
 addomain.acme.org = ADDOMAIN.ACME.ORG
 .addomain.acme.org = ADDOMAIN.ACME.ORG
 ```
6. Setup SAMBA configuration by setting the following entries in /etc/samba/smb.conf in identified section. Please ensure that there is only one line corresponding to workgroup.
```
[global]
 
workgroup = ACMEORG
client signing = yes
client use spnego = yes
kerberos method = secrets and keytab
realm = ADDOMAIN.ACME.ORG
security = ads
Create SSSD conf file (/etc/sssd/sssd.conf) with following details

[sssd]
services = nss, pam
config_file_version = 2
domains = addomain.acme.org
 
[domain/addomain.acme.org]
ad_domain = addomain.acme.org
krb5_realm = ADDOMAIN.ACME.ORG
realmd_tags = manages-system joined-with-samba
cache_credentials = True
krb5_store_password_if_offline = True
default_shell = /bin/bash
ldap_id_mapping = True
use_fully_qualified_names =  False
fallback_homedir =  /home/%u
override_homedir =  /home/%u
 
id_provider = ad
access_provider = ad
 
# Use this if users are being logged in at /.
# This example specifies /home/DOMAIN-FQDN/user as $HOME.  Use with pam_mkhomedir.so
#override_homedir = /home/%d/%u
 
# Uncomment if the client machine hostname doesn't match the computer object on the DC.
# ad_hostname = mymachine.myubuntu.example.com
 
# Uncomment if DNS SRV resolution is not working
# ad_server = dc.mydomain.example.com
 
# Uncomment if the AD domain is named differently than the Samba domain
# ad_domain = MYUBUNTU.EXAMPLE.COM
 
# Enumeration is discouraged for performance reasons.
# enumerate = true
```

7. Change permission on the file
```
sudo chmod 600 /etc/sssd/sssd.conf
sudo chown root:root /etc/sssd/sssd.conf
```
8. Add the following line to /etc/pam.d/common-session
```
session    required    pam_mkhomedir.so skel=/etc/skel/ umask=0022
```
after the following line
```
session required        pam_unix.so
```
9. Add the following line to /etc/sudoers file
```
%ACMEAdmins ALL=(ALL)ALL
```
10. Restart services
```
sudo systemctl restart chrony.service
sudo systemctl restart smbd.service nmbd.service
```
11. Add the server to AD
```
sudo net ads join -U ad-admin@ADDOMAIN.ACME.ORG
```
