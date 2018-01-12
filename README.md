# ubnt-edgerouter-interface-reset
A simple remote healthcheck script with the ability to reset a VPN tunnel or other interface if it is hung or otherwise down

## Assumptions

This script assumes you have LAN connectivity to the EdgeRouter. You must be able to connect to it for this to work.

## Use case

This was written to reset unstable VPN connections automatically when they hang but don't reset. It can be used for any type of interface that supports `disable`

## How to use

Put this in cron on a host in your LAN. When it executes, it will check for Internet connectivity and if it fails, it will reset a specific interface in the EdgeRouter using the `configure` CLI. This is meant to be used for unreliable VPN interfaces but it can be used for any type of interface by modifying `IFACE_NAME` and `IFACE_TYPE`. You will have to have SSH access set up so that SSH works without a password. You can do this poorly with `sshpass -p <password>` or you can do this correctly with an SSH key.

## Adding an SSH public key to an EdgeRouter and setting up and testing passwordless access

First, generate an SSH keypair on your own machine and copy the public key to the EdgeRouter. Make sure to leave the key unprotected by a password if you want it to run unattended by pressing enter when prompted for a passphrase by ssh-keygen

```
$ ssh-keygen -t ecdsa -f ~/.ssh/id_ecdsa.ubnt
$ scp ~/.ssh/id_ecdsa.ubnt.pub edgerouter:/tmp/pubkey
$ chmod -R 700 ~/.ssh
```

Next, make sure you have an SSH config entry for your EdgeRouter that is set to use your key

```
$ cat ~/.ssh/config
Host erlite
    HostName 192.168.1.1
    User ubnt
    IdentityFile ~/.ssh/id_ecdsa.ubnt
```

Test to make sure your SSH configuration works

```
$ ssh erlite id
Welcome to EdgeOS

By logging in, accessing, or using the Ubiquiti product, you
acknowledge that you have read and understood the Ubiquiti
License Agreement (available in the Web UI at, by default,
http://192.168.1.1) and agree to be bound by its terms.

uid=1000(ubnt) gid=100(users) groups=4(adm),6(disk),27(sudo),30(dip),100(users),102(vyattacfg),104(quaggavty)
$
```

Add the public key so that it is authorized for the ubnt user on the EdgeRouter

```
ubnt@erlite:~$ sudo -i
# configure
# loadkey ubnt /tmp/pubkey
# commit
# save
# exit
ubnt@erlite:~$ 
```

**WARN**: do NOT simply copy the key to ~/.ssh/authorized_keys, it will be wiped out upon reboot !!

## Notes

You may need to add your user to the `cron` group in /etc/group depending on your Linux distribution (or UNIX operating system) in order to allow your user to have a cron entry