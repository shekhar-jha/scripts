
# Red Hat Enterprise Linux Server release 7.2 (Maipo) (HVM)

## Security

### Firewall Disable
If needed stop firewall (not enabled or available)
```
systemctl status firewalld
service firewalld stop
systemctl disable firewalld
```

### Firewall Open specific ports
```
firewall-cmd --zone=public --add-port=80/tcp --permanent
```
### Disable SELinux
```
sed 's/enforcing/disabled/g' -i /etc/sysconfig/selinux
sed 's/enforcing/disabled/g' -i /etc/selinux/config
```
### Disable Services
```
sudo systemctl stop postfix
sudo systemctl disable postfix
```

### Create new user

```
useradd -c "Product specific user" -d /home/demo -g users -m -N demo
```
Add the new user `demo` to `/etc/sudoers` to give sudo privilege without password for all commands.
```
demo ALL=(ALL) NOPASSWD:ALL
```

## Configuration

### Timezone
```
timedatectl set-timezone America/New_York
```
### Setup Disk

#### Setup new disk as physical volume

```
> fdisk /dev/xvdb`
Welcome to fdisk (util-linux 2.23.2).

Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.

Device does not contain a recognized partition table
Building a new DOS disklabel with disk identifier ------

Command (m for help): n
Command action
   e   extended
   p   primary partition (1-4)
Select (default p): p
Partition number (1-4): 1
First cylinder (1-6527, default 1): 1
Last cylinder, +cylinders or +size{K,M,G} (1-6527, default 6527): [Enter]
Using default value 6527
Partition 1 of type Linux and of size 50 GiB is set

Command (m for help): w
The partition table has been altered!

Calling ioctl() to re-read partition table.
Syncing disks.
```

#### Format the new volume created

```
> mkfs.ext4 -L Product /dev/xvdb1
mke2fs 1.42.9 (28-Dec-2013)
Filesystem label=Product
OS type: Linux
Block size=4096 (log=2)
Fragment size=4096 (log=2)
Stride=0 blocks, Stripe width=0 blocks
3276800 inodes, 13106944 blocks
655347 blocks (5.00%) reserved for the super user
First data block=0
Maximum filesystem blocks=2162163712
400 block groups
32768 blocks per group, 32768 fragments per group
8192 inodes per group
Superblock backups stored on blocks: 
	32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632, 2654208, 
	4096000, 7962624, 11239424

Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (32768 blocks): done
Writing superblocks and filesystem accounting information: done  
```
#### Create a new directory and mount formatted volume

```
mkdir /opt/product
mount -t ext4 /dev/xvdb1 /opt/product/
chown demo:users /opt/product/
```
#### Configure to automatic mount new file system

Add the new disk in mount file `/etc/fstab`<br/>
`/dev/xvdb1              /opt/product             ext4    defaults        0 2`

### Swap file setup

#### Create swap file

```
mkdir /opt/swap
cd /opt/swap
dd if=/dev/zero of=/opt/swap/swapfile bs=1024 count=2MB
```
#### Format swap file

```
mkswap /opt/swap/swapfile
```
### Configure to automatic mount new swap file
```
cp /etc/fstab /etc/fstab.bak
echo "/opt/swap/swapfile          swap            swap    defaults        0 0" >>/etc/fstab`
```
## Change hostname

1. Add `preserve_hostname: true` at end of the `/etc/cloud/cloud.cfg` file on your RHEL 7 or Centos 7 Linux instance to ensure that hostname is preserved after reboot.
2. Run the following command to set the new name.
```
hostnamectl set-hostname <new host name>.demo.ap
```

Add the new name to `/etc/hosts` file to ensure that it is resolved correctly.

# Update
Update the install
```
yum update
```

# DHCP Configuration
Override DNS Configuration provided as part of DHCP. Add the following entry to `/etc/dhcp/dhclient.conf` file
```
supersede domain-name-servers 8.8.8.8;
```
