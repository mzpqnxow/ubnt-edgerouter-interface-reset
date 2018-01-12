# ubnt-edgerouter-interface-reset
A simple remote healthcheck script with the ability to reset a VPN tunnel or other interface if it is hung or otherwise down

## Assumptions

This script assumes you have LAN connectivity to the EdgeRouter. You must be able to connect to it for this to work.

## Use case

This was written to reset unstable VPN connections automatically when they hang but don't reset

## How to use

Put this in cron on a host in your LAN. When it executes, it will check for Internet connectivity and if it fails, it will reset a specific interface in the EdgeRouter using the `configure` CLI. This is meant to be used for unreliable VPN interfaces but it can be used for any type of interface by modifying `IFACE_NAME` and `IFACE_TYPE`

## Notes

You may need to add your user to the `cron` group in /etc/group depending on your Linux distribution (or UNIX operating system) in order to allow your user to have a cron entry