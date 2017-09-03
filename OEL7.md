Oracle Enterprise Linux 7.1 with Docker

# Base Installation (not production)

1. Language : English (United States)
2. Date and Time: Chicago as Timezone, After enabling Network, enable NTP
3. Installation Destination: Default Partitioning using LVOL & XFS file system
4. Network & Hostname: iam.jhash.com, Select the MAC Address in configuration and select connect whenever available
5. Set root password and create a new user demo with admin access
6. Software selection minimal
7. Ensure that there are two networks
  1. Network Host Only & VNet0 is selected. - This is for connectivity from local machine (Virtual Box)
  2. NAT - this is to connect to outside world from machine

# Configuration

## Basic
1. Login using demo
2. sudo yum update (multiple times) and reboot
3. sudo systemctl stop firewalld
4. sudo systemctl disable firewalld

## Docker
* sudo su -
* cat >/etc/yum.repos.d/docker.repo <<-EOF
```
 [dockerrepo]
 name=Docker Repository
 baseurl=https://yum.dockerproject.org/repo/main/centos/7
 enabled=1
 gpgcheck=1
 gpgkey=https://yum.dockerproject.org/gpg
 EOF
```
* sudo yum install docker-engine
* sudo usermod -aG docker demo
* sudo chkconfig docker on
* Docker Compose
```
curl -L https://github.com/docker/compose/releases/download/1.4.0/docker-compose-`uname -s`-`uname -m` > docker-compose
sudo mv docker-compose /usr/local/bin
chmod +x /usr/local/bin/docker-compose
```
* TODO: add code to profile to automatically update docker-compose on start.

## OEL 
* docker run oraclelinux:7.0

## Notes

1. Docker can be installed from Oracle Yum
  1. Edit /etc/yum.repos.d/public-yum-ol7.repo and set enabled=1 in the [ol7_addons] stanza.
  2. sudo yum install docker
  3. sudo systemctl start docker.service
  4. sudo systemctl enable docker.service
  5. sudo yum remove docker
