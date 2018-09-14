This contains tips and tricks for SSH

# SSH Config
SSH configuration can simplify the connectivity a lot by creating shortcuts that enable/disable a particular capability of ssh without creating multiple command files.

Sample SSH config file with annotations. Please note that ssh config file should be located in `~/.ssh/config`
```
# Servers
# At the start define all the servers you need access to. This allows you to give simple name for IP addresses without bothering with DNS.
Host hyperledger*
     HostName 192.168.1.89
     User demo

# If you use two ids (e.g. admin & user), create entry similar to one below to map to 
# Host hyperledger*admin*
#     HostName 192.168.1.89
#     User admin

# If you have shared ID files accross all your admin servers, you can add it as follows
# Host *admin*
#     IdentityFile ~/.ssh/admin.pem

# Just add X to end of the server name above to enable X11
# i.e. use hostname "hyperledgerX" or "hyperledgeradminX"
Host *X*
    ForwardX11 yes

# Just add oimtunnel to end of the server name above to setup tunnel
# i.e. use hostname "hyperledgerXoimtunnel" or "hyperledgeroimtunnel"
Host *oimtunnel*
    LocalForward 14000 oiam12c:14000

# This section automatically configures all the tunnels to work correctly with existing server.
Host *tunnel*
    ControlMaster auto
    ControlPath ~/.ssh/sockets/%r@%h:%p
 
# Need this to avoid disconnections due to overjealous firewalls.
Host *
    ServerAliveInterval 10
```

