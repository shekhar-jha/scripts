

# Download Installers

```
# Ensure that cookie.txt has been created by exporting using an Addon after login to following websites
# http://www.oracle.com/technetwork/middleware/webtier/downloads/index-jsp-156711.html
# http://www.oracle.com/technetwork/middleware/id-mgmt/downloads/oid-11gr2-2104316.html
# http://support.oracle.com

# OHS including weblogic proxy plugin & webgate
wget --load-cookies=./cookies.txt --no-check-certificate "http://download.oracle.com/otn/linux/middleware/12c/12213/fmw_12.2.1.3.0_ohs_linux64_Disk1_1of1.zip?AuthParam=1527782833_7f86917bcab8304203dd6c9c5e49ab57" -O fmw_12.2.1.3.0_ohs_linux64_Disk1_1of1.zip

# OIAM 
wget --load-cookies=./cookies.txt --no-check-certificate "http://download.oracle.com/otn/nt/middleware/12c/12213/fmw_12.2.1.3.0_idmqs_Disk1_1of2.zip" -O fmw_12.2.1.3.0_idmqs_Disk1_1of2.zip
wget --load-cookies=./cookies.txt --no-check-certificate "http://download.oracle.com/otn/nt/middleware/12c/12213/fmw_12.2.1.3.0_idmqs_Disk1_2of2.zip" -O fmw_12.2.1.3.0_idmqs_Disk1_2of2.zip
wget --load-cookies=./cookies.txt --no-check-certificate "http://download.oracle.com/otn/nt/middleware/12c/12213/fmw_12.2.1.3.0_infrastructure_Disk1_1of1.zip" -O fmw_12.2.1.3.0_infrastructure_Disk1_1of1.zip
wget --load-cookies=./cookies.txt --no-check-certificate "http://download.oracle.com/otn/nt/middleware/12c/12213/fmw_12.2.1.3.0_idm_Disk1_1of1.zip" -O fmw_12.2.1.3.0_idm_Disk1_1of1.zip
# OUD
wget --load-cookies=./cookies.txt --no-check-certificate "http://download.oracle.com/otn/nt/middleware/12c/12213/fmw_12.2.1.3.0_oud_Disk1_1of1.zip" -O fmw_12.2.1.3.0_oud_Disk1_1of1.zip
# OAM Webgate Patch (12.2.1.3.180414)
wget --load-cookies=./cookies.txt --no-check-certificate "https://updates.oracle.com/Orion/Services/download/p27863709_122130_Linux-x86-64.zip?aru=22113013&patch_file=p27863709_122130_Linux-x86-64.zip" -O p27863709_122130_Linux-x86-64.zip
# OIAM Patch (IDM SUITE BUNDLE PATCH 12.2.1.3.180417)
wget --load-cookies=./cookies.txt --no-check-certificate "https://updates.oracle.com/Orion/Services/download/p27704994_122130_Generic.zip?aru=22039066&patch_file=p27704994_122130_Generic.zip" -O p27704994_122130_Generic.zip

```
