
# Docker

### Installing docker

1. Install docker
```bash
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
```bash
# groupadd docker
usermod -aG docker <user id>
```
3. Add the ip address to `/etc/hosts`
```
<ip address> docker-host
```
4. Create the configuration for docker daemon `/etc/docker/daemon.json`
```bash
cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ]
}
EOF
mkdir -p /etc/systemd/system/docker.service.d
```
> **Note:**
>
> 1. Adding `"hosts": ["unix:///var/run/docker.sock", "tcp://docker-host:2375"]` should allow connecting remotely. But with current builds it is not working.
> 2. Using `systemd` as `cgroup` driver is recommended 
5. Restart
```bash
systemctl daemon-reload
systemctl restart docker
```

# Kubernetes

## Master

### Prerequisites

1. Ensure that machine has atleast 2 network adapters (preferrably on separate network - management and public) and the corresponding names are updated.
```bash
sudo su - 
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
> Need to understand whether multiple network adapter based management & application traffic separation is necessary.
> 1. May need to revisit whether standardization of network adapter name will simplify any kubernetes configuration across all the nodes.
> 2. Standard naming of adapter name can be security issue?
> 3. Some guidance include need to add/update `/usr/lib/udev/rules.d/60-net.rules` file. But it looks like that is not needed for CentOS 7.
2. Ensure that docker is installed (See above for steps) 
3. Ensure that mac address and product id are unique across the cluster
```bash
ip link
cat /sys/class/dmi/id/product_uuid
```
4. Ensure that sway is disabled by checking the swap line in `/etc/fstab` file
```
#/dev/mapper/centos_centos7--base-swap swap                    swap    defaults        0 0
  
```
5. Ensure that machine has atleast 2 cores configured and atleast 2 GB RAM.

### Setup basic kubernetes

1. Update the hardware address in scripts to ensure network interface names are updated
```bash
sudo su - 
cd /etc/sysconfig/network-scripts 
sed -i.backup '/HWADDR/d' ifcfg-app
sed -i.backup '/HWADDR/d' ifcfg-mgmt
echo 'HWADDR="<mac>"' >> ifcfg-app
echo 'HWADDR="<mac>"' >> ifcfg-mgmt
```
2. Change the name of the server
```bash
hostnamectl set-hostname k8-master-1
```
3. Add the following entry in to `/etc/hosts` for configuration purpose
```
<mgmt ip address> k8-master-1 
<mgmt ip address> docker-host
<external ip address> k8-master-1-app
```
4. For CentOS/RHEL - Execute the following command to fix traffic routing issue
```bash
modprobe br_netfilter
cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system
```
5. Disable SE Linux (Master Only???)
```bash
setenforce 0
sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
```
> **Note**
> Need to revisit this but looks like this is standard guidance of installation process
6. Setup firewall
```bash
sudo su - 
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
firewall-cmd --reload
firewall-cmd --permanent --zone=k8s-mgmt-master --add-interface=mgmt
```
7. Create new user `k8admin`
```bash
useradd -c "Kubernates Admin" -m k8admin
```
8. Install Kubernetes server binaries
```bash
sudo su - bash
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kube*
EOF
yum install kubeadm --disableexcludes=kubernetes
systemctl enable --now kubelet
```
9. Cleanup any existing cluster (Optional)
```bash
kubectl drain k8-master-1 --delete-local-data --force --ignore-daemonsets
kubectl delete node k8-master-1
kubeadm reset
iptables -F && iptables -t nat -F && iptables -t mangle -F && iptables -X
```
10.Initialize cluster on master node
```bash
sudo su -
kubeadm config images pull
# Stop firewall to ensure that setup can be completed.
systemctl stop firewalld
kubeadm init --pod-network-cidr=10.10.0.0/16 --apiserver-advertise-address=192.168.126.130
```
> **Note**
>
> 1. `apiserver-advertise-address` allows you to bind api server to mgmt interface
> 2. `pod-network-cidr` is specified since we want to use calico which needs this value to be specified.
> 3. Output of interest
> ```
> [WARNING Firewalld]: firewalld is active, please ensure ports [6443 10250] are open or your cluster may not function correctly
> [kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
> [kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
> [certs] Using certificateDir folder "/etc/kubernetes/pki"
> [kubeconfig] Using kubeconfig folder "/etc/kubernetes"
> [control-plane] Using manifest folder "/etc/kubernetes/manifests"
> [bootstrap-token] Using token: 022uy8.3tb96nyxg7meusae
> kubeadm join 192.168.126.130:6443 --token 022uy8.3tb96nyxg7meusae \
>     --discovery-token-ca-cert-hash sha256:0e4787937e0842e90cd8b38d9d8f76d6ddc8e8512bd61b8b6735db77b7898d1b 
> ```
11. Enable `k8admin` & `root` user to control setup
```bash
sudo su -
mkdir -p ~k8admin/.kube
cp -i /etc/kubernetes/admin.conf ~k8admin/.kube/config
chown $(id -u k8admin):$(id -g k8admin) ~k8admin/.kube/config
mkdir -p ~/.kube
cp -i /etc/kubernetes/admin.conf ~/.kube/config
chown $(id -u):$(id -g) ~/.kube/config
```
12. Check status of environment
```console
# sudo su - k8admin
$ kubectl get nodes
NAME         STATUS    AGE       VERSION
k8-master-1   NotReady   master   8m9s   v1.14.0
$ kubectl  get pods  --all-namespaces
NAMESPACE     NAME                                  READY   STATUS    RESTARTS   AGE
kube-system   coredns-fb8b8dccf-jv7nr               0/1     Pending   0          9m11s
kube-system   coredns-fb8b8dccf-mssff               0/1     Pending   0          9m11s
kube-system   etcd-k8-master-1                      1/1     Running   0          8m24s
kube-system   kube-apiserver-k8-master-1            1/1     Running   0          8m4s
kube-system   kube-controller-manager-k8-master-1   1/1     Running   0          8m10s
kube-system   kube-proxy-rdmb4                      1/1     Running   0          9m11s
kube-system   kube-scheduler-k8-master-1            1/1     Running   0          8m21s
```

### Setup Calico as Network Add On

> **Note** 
> Before the kubernetes network can configure itself and stabalize, the firewall needs to be switched off.
> This means that during initial configuration and after the server re-boot, firewalld needs to be shutdown and then restarted after all the pods are in running mode.
> ```bash
> systemctl stop firewalld
> ```

1. Install pod network add-on to build network that will connect all the pods across the cluster
```bash
sudo su - k8admin
curl -OL https://docs.projectcalico.org/v3.6/getting-started/kubernetes/installation/hosted/kubernetes-datastore/calico-networking/typha/calico.yaml
POD_CIDR="10.10.0.0/16"
sed -i -e "s?192.168.0.0/16?$POD_CIDR?g" calico.yaml
kubectl apply -f calico.yaml
```
> **Note**
>
> 1. There are multiple network add-ons available but this focuses on using calico.
> 2. Modify the replica count in the `Deployment` named `calico-typha` to the desired number of replicas.
> 3. Recommend at least one replica for every 200 nodes and no more than 20 replicas. In production, we recommend a minimum of three replicas to reduce the impact of rolling upgrades and failures.
> 4. Could not make this setup work with firewall enabled. Was getting errors about connecting to API-Server from Calico & DNS pods
2. Install `calicoctl` tool
```bash
sudo su - 
curl -O -L  https://github.com/projectcalico/calicoctl/releases/download/v3.6.1/calicoctl
mv calicoctl /usr/bin
chmod +x /usr/bin/calicoctl
```
3. Check network status
```bash
DATASTORE_TYPE=kubernetes KUBECONFIG=~k8admin/.kube/config calicoctl get bgpConfiguration
DATASTORE_TYPE=kubernetes KUBECONFIG=~k8admin/.kube/config calicoctl get bgpPeer
DATASTORE_TYPE=kubernetes KUBECONFIG=~k8admin/.kube/config calicoctl get felixConfiguration
DATASTORE_TYPE=kubernetes KUBECONFIG=~k8admin/.kube/config calicoctl get globalNetworkPolicy
DATASTORE_TYPE=kubernetes KUBECONFIG=~k8admin/.kube/config calicoctl get globalNetworkSet
DATASTORE_TYPE=kubernetes KUBECONFIG=~k8admin/.kube/config calicoctl get hostEndpoint
DATASTORE_TYPE=kubernetes KUBECONFIG=~k8admin/.kube/config calicoctl get networkPolicy
DATASTORE_TYPE=kubernetes KUBECONFIG=~k8admin/.kube/config calicoctl get workloadEndpoint
DATASTORE_TYPE=kubernetes KUBECONFIG=~k8admin/.kube/config calicoctl get ipPool
DATASTORE_TYPE=kubernetes KUBECONFIG=~k8admin/.kube/config calicoctl get node
DATASTORE_TYPE=kubernetes KUBECONFIG=~k8admin/.kube/config calicoctl get profile
```
4. After the cluster reaches stable state, start the firewall
```bash
systemctl start firewalld
```

### Setup Kubernetes Dashboard

1. Create a new `admin-user` to access kubernetes
   * Create a new file `admin-user.yaml` with following content
```yaml
   apiVersion: v1
   kind: ServiceAccount
   metadata:
     name: admin-user
     namespace: kube-system
   ---
   apiVersion: rbac.authorization.k8s.io/v1
   kind: ClusterRoleBinding
   metadata:
     name: admin-user
   roleRef:
     apiGroup: rbac.authorization.k8s.io
     kind: ClusterRole
     name: cluster-admin
   subjects:
   - kind: ServiceAccount
     name: admin-user
     namespace: kube-system
```
   * Add it to kubernetes
```
   kubectl apply -f ./admin-user.yaml
```
2. Install Web UI Dashboard to monitor environment
```bash
sudo su - 
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/master/aio/deploy/recommended/kubernetes-dashboard.yaml
```
3. Before accessing the environment, run the following setup
   * Create a tunnel from your local machine to master node
   ```bash
   ssh -o ServerAliveInterval=60 -L 8001:localhost:8001 -f -l root -N 192.168.126.132
   ```
   * Generate login token for the admin-user
   ```bash
   kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep admin-user | awk '{print $1}')
   ```
   * Start kubernetes proxy to allow access to API server on localhost
   ```bash
   kubectl proxy &
   ```
4. Access the web UI at `http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/`

## Node

### Pre-requisites

See Master for pre-requisites

### Install

1. Change the name of the server
```
hostnamectl set-hostname k8-node-1
```
2. Add the following entry in to `/etc/hosts` for configuration purpose
```
<mgmt ip address> k8-node-1 docker-host
<external ip address>  k8-node-1-app
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

## Commands

### See all logs
```
for container in `docker ps --format "{{.ID}}"`; do echo "--------------------------------------"; docker ps --filter "id=${container}"; echo "--------------------------------------"; docker logs $container | more; done
```
