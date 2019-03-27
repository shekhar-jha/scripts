
# Docker

### Installing docker

1. Install docker
```
sudo su - bash
yum install -y yum-utils \
  device-mapper-persistent-data \
  lvm2
yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo  
sudo yum install docker-ce docker-ce-cli containerd.io
# yum install docker
systemctl start docker
systemctl enable docker
```
2. Add user to docker id
```
# groupadd docker
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
5. Restart
```
systemctl restart docker
```

# Kubernetes

## Master

### Prerequisites

1. Ensure that machine is appropriate name
```
hostnamectl set-hostname k8-master
```
2. Ensure that machine has atleast 2 network adapters (preferrably on separate network - management and public)
> **Note**
> Need to understand whether multiple network adapter based management & application traffic separation is necessary.
3. Ensure that docker is installed (See above for steps) 
4. Ensure that mac address and product id are unique across the cluster
```
ip link
cat /sys/class/dmi/id/product_uuid
```

### Install

1. Add the following entry in to `/etc/hosts` for configuration purpose
```
<mgmt ip address> k8-master-1 docker-host
<external ip address> k8-master-1-app
```
2. Change the network adapter name to `app` & `mgmt`. Please replace `ens33` with name of corresponding network adapter in the server. Also, replace `<mac>` with corresponding MAC address of adapter.
```
sudo su - bash
cd /etc/sysconfig/network-scripts
cp ifcfg-ens33 ifcfg-app
cp ifcfg-ens33 ifcfg-mgmt
mv ifcfg-ens33 backup.ifcfg-ens33
sed -i.backup '/UUID/d' ifcfg-app
sed -i.backup '/UUID/d' ifcfg-mgmt
sed -i.backup 's/ens33/app/g' ifcfg-app
sed -i.backup 's/ens33/mgmt/g' ifcfg-mgmt
echo 'HWADDR="<mac>"' >> ifcfg-app
echo 'HWADDR="<mac>"' >> ifcfg-mgmt
```
> **Note**
>
> 1. May need to revisit whether standardization of network adapter name will simplify any kubernetes configuration across all the nodes.
> 2. Standard naming of adapter name can be security issue?
> 3. Some guidance include need to add/update `/usr/lib/udev/rules.d/60-net.rules` file. But it looks like that is not needed for CentOS 7.
3. Setup firewall
```
sudo su - bash
firewall-cmd --permanent --new-service=docker-server
firewall-cmd --permanent --service=docker-server --set-description="Docker Server API"
firewall-cmd --permanent --service=docker-server --set-short="docker-server"
firewall-cmd --permanent --service=docker-server --add-port=2375/tcp
firewall-cmd --permanent --new-service=k8s-api-server
firewall-cmd --permanent --service=k8s-api-server --set-description="Kubernetes API server"
firewall-cmd --permanent --service=k8s-api-server --set-short="kubernate-api-server"
firewall-cmd --permanent --service=k8s-api-server --add-port=6443/tcp
firewall-cmd --permanent --new-service=k8s-etcd-client-api
firewall-cmd --permanent --service=k8s-etcd-client-api --set-description="etcd server client API"
firewall-cmd --permanent --service=k8s-etcd-client-api --set-short="etcd-client-api"
firewall-cmd --permanent --service=k8s-etcd-client-api --add-port=2379-2380/tcp
firewall-cmd --permanent --new-service=k8s-kubelet-api
firewall-cmd --permanent --service=k8s-kubelet-api --set-description="Kubelet API"
firewall-cmd --permanent --service=k8s-kubelet-api --set-short="kubelet-api"
firewall-cmd --permanent --service=k8s-kubelet-api --add-port=10250/tcp
firewall-cmd --permanent --new-service=k8s-kube-scheduler
firewall-cmd --permanent --service=k8s-kube-scheduler --set-description="kube-scheduler"
firewall-cmd --permanent --service=k8s-kube-scheduler --set-short="kube-scheduler"
firewall-cmd --permanent --service=k8s-kube-scheduler --add-port=10251/tcp
firewall-cmd --permanent --new-service=k8s-kube-controller-manager
firewall-cmd --permanent --service=k8s-kube-controller-manager --set-description="kube-controller-manager"
firewall-cmd --permanent --service=k8s-kube-controller-manager --set-short="kube-controller-manager"
firewall-cmd --permanent --service=k8s-kube-controller-manager --add-port=10252/tcp
firewall-cmd --reload
firewall-cmd --permanent --new-zone k8s-mgmt-master
firewall-cmd --permanent --zone=k8s-mgmt-master --add-interface=mgmt
firewall-cmd --permanent --zone=k8s-mgmt-master --add-service=k8s-api-server
firewall-cmd --permanent --zone=k8s-mgmt-master --add-service=k8s-etcd-client-api
firewall-cmd --permanent --zone=k8s-mgmt-master --add-service=k8s-kubelet-api
firewall-cmd --permanent --zone=k8s-mgmt-master --add-service=k8s-kube-scheduler
firewall-cmd --permanent --zone=k8s-mgmt-master --add-service=k8s-kube-controller-manager
firewall-cmd --permanent --zone=k8s-mgmt-master --add-service=docker-server
# To allow assignment of IP using DHCP to mgmt interface
firewall-cmd --permanent --zone=k8s-mgmt-master --add-service=dhcpv6-client
# To allow ssh access on mgmt interface
firewall-cmd --permanent --zone=k8s-mgmt-master --add-service=ssh
```
2. Download Kubernetes server binaries
```
sudo su - bash
cd /opt
mkdir installers
cd installers
curl -OL https://dl.k8s.io/v1.14.0/kubernetes-server-linux-amd64.tar.gz
```

## Node

### Pre-requisites

See Master for pre-requisites

### Install

1. Add the following entry in to `/etc/hosts` for configuration purpose
```
<mgmt ip address> k8-node-1 docker-host
<external ip address>  k8-node-1-app
```
2. Change the network adapter name to `app` & `mgmt`. Please replace `ens33` with name of corresponding network adapter in the server. Also, replace `<mac>` with corresponding MAC address of adapter.
```
sudo su - bash
cd /etc/sysconfig/network-scripts
cp ifcfg-ens33 ifcfg-app
cp ifcfg-ens33 ifcfg-mgmt
mv ifcfg-ens33 backup.ifcfg-ens33
sed -i.backup '/UUID/d' ifcfg-app
sed -i.backup '/UUID/d' ifcfg-mgmt
sed -i.backup 's/ens33/app/g' ifcfg-app
sed -i.backup 's/ens33/mgmt/g' ifcfg-mgmt
echo 'HWADDR="<mac>"' >> ifcfg-app
echo 'HWADDR="<mac>"' >> ifcfg-mgmt
```
3. Setup firewall
```
firewall-cmd --permanent --new-service=k8s-kubelet-api
firewall-cmd --permanent --service=k8s-kubelet-api --set-description="Kubelet API"
firewall-cmd --permanent --service=k8s-kubelet-api --set-short="kubelet-api"
firewall-cmd --permanent --service=k8s-kubelet-api --add-port=10250/tcp
firewall-cmd --permanent --new-service=k8s-node-services
firewall-cmd --permanent --service=k8s-node-services --set-description="NodePort Services"
firewall-cmd --permanent --service=k8s-node-services --set-short="node-services"
firewall-cmd --permanent --service=k8s-node-services --add-port=30000-32767/tcp
firewall-cmd --reload
firewall-cmd --permanent --new-zone k8s-mgmt-node
firewall-cmd --permanent --zone=k8s-mgmt-node --add-interface=mgmt
firewall-cmd --permanent --zone=k8s-mgmt-node --add-service=k8s-kubelet-api
firewall-cmd --permanent --zone=k8s-mgmt-node --add-service=k8s-node-services
# To allow assignment of IP using DHCP to mgmt interface
firewall-cmd --permanent --zone=k8s-mgmt-node --add-service=dhcpv6-client
# To allow ssh access on mgmt interface
firewall-cmd --permanent --zone=k8s-mgmt-node --add-service=ssh

```

2. Download kubernetes node binaries
```
sudo su - bash
cd /opt
mkdir installers
cd installers
curl -OL https://dl.k8s.io/v1.14.0/kubernetes-node-linux-amd64.tar.gz
```
