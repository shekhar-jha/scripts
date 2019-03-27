
# Docker

### Installing docker

1. Install docker
```
yum install docker
systemctl start docker
systemctl enable docker
```
2. Add user to docker id
```
groupadd docker
usermod -aG docker <user id>
```
3. Add the ip address to `/etc/hosts`
```
<ip address> docker-host
```
4. Add the following line to `/etc/docker/daemon.json`
```
{
    "hosts" : [ "unix:///var/run/docker.sock", "tcp://docker-host:2375"]
}
```

### 

