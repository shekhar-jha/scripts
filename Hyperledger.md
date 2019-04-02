
# Setup

## Prerequisite
1. Update host ip in /etc/hosts & reboot
2. Change hostname to hyperledger
```
   hostnamectl set-hostname hyperledger
```
3. Add hostname entry to `/etc/hosts` file
```
<external-host>  docker-host
```
4. Install bash-completion, net-tools & bzip2
```
yum update
yum install net-tools
yum install bash-completion
yum install bzip2
```
5. Create a user `hyperledger`
```
useradd -c "Hyperledger Admin" -m hyperledger
```
6. Install docker
```
    yum install docker
    groupadd docker
    usermod -aG docker hyperledger
    systemctl start docker
    systemctl enable docker
```
7. Configure docker for external access by adding the following line to `/etc/docker/daemon.json`
```
   {
     "hosts": ["unix:///var/run/docker.sock", "tcp://docker-host:2375"]
   }
```
8. Open firewall port
```
    sudo firewall-cmd --zone=public --add-port=2375/tcp --permanent
    sudo firewall-cmd --reload
```
9. Install compose
```
   sudo curl -L "https://github.com/docker/compose/releases/download/1.22.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
   sudo chmod +x /usr/local/bin/docker-compose
   sudo curl -L https://raw.githubusercontent.com/docker/compose/1.22.0/contrib/completion/bash/docker-compose -o /etc/bash_completion.d/docker-compose
```

## Installation

1. Install dependencies
```
   yum install golang
   yum install git
```
2. Install hyperledger
```
   sudo mkdir /opt/hyperledger-1.2.0
   cd /opt/
   sudo ln -sf hyperledger-1.2.0 hyperledger
   sudo chown hyperledger:hyperledger hyperledger-1.2.0/
   sudo su - hyperledger
   cd /opt/hyperledger
   curl -sSL http://bit.ly/2ysbOFE | bash -s 1.2.0
```
3. Add following line to ~hyperledger/.bash_profile
```
   export PATH=$PATH::/usr/local/bin:/opt/hyperledger/fabric-samples/bin
```

### Setup samples

1. Install samples to kick-start setup
```
   sudo su - hyperledger
   cd /opt/hyperledger-1.2.0/
   git clone -b master https://github.com/hyperledger/fabric-samples.git && cd fabric-samples && git checkout v1.2.0
```

### Setup Hyperledger client CA management tool

1. Install following for CA Client
```
sudo yum install libtool libltdl-dev
```
13. Install CA Client
```
go get -u github.com/hyperledger/fabric-ca/cmd/fabric-ca-client
```

