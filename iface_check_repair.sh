#!/bin/bash
#
# To run this batched, either use sshpass or set up
# a key on the EdgeRouter and an entry in your ~/.ssh/config
# like this:
#
# Host keeper
#     HostName 10.1.1.1
#     User ubnt
#     IdentityFile /home/username/.ssh/id_rsa
#
# Copyright (C) 2018, copyright@mzpqnxow.com
# For Copyright terms, see LICENSE or LICENSE.md
#
IFACE_NAME=vtun0    # Interface name
IFACE_TYPE=openvpn  # Interface type
ER_HOSTNAME=keeper  # Hostname of the EdgeRouter device

# Don't bother modifying anything below here
NC=nc.traditional
NC_FLAGS=
SED=sed
CAT=cat
HEALTHCHECK_HOST=google.com # Consider interface broken if TCP connection can't be built
HEALTHCHECK_PORT=81
CONNECT_TIMEOUT=10

function fatal() {
    echo "FATAL: $1"
    exit
}

which $NC >/dev/null || fatal "unable to find netcat !!"
which $SED >/dev/null || fatal "unable to find sed !!"
which $CAT >/dev/null || fatal "unable to find cat !!"
echo "Checking connectivity using endpoint $HEALTHCHECK_HOST:$HEALTHCHECK_PORT ..."
$NC $NC_FLAGS -z -w $CONNECT_TIMEOUT $HEALTHCHECK_HOST $HEALTHCHECK_PORT
if [ $? -ne 0 ]; then
    echo "Unable to connect to Internet, VPN seems down or hung ..."
    echo "Creating local temporary file for script ..."
    TMPFILE=$(mktemp)
    BASE_TMPFILE=$(basename $TMPFILE)
    echo "Building repair script @ $TMPFILE ..."
    $CAT > $TMPFILE << 'EOF'
#!/bin/vbash
source /opt/vyatta/etc/functions/script-template
configure
set interfaces openvpn %IFACE_NAME% disable
commit
delete interfaces openvpn %IFACE_NAME% disable
commit
exit
rm -- "$0"
EOF
    sed -i -e "s/%IFACE_NAME%/$IFACE_NAME/" $TMPFILE
    chmod 755 $TMPFILE
    echo "Copying repair script to EdgeRouter ..."
    scp $TMPFILE $ER_HOSTNAME: || fail "Unable to SCP script to $ER_HOSTNAME !!"
    echo "Executing repair script on EdgeRouter ..."
    ssh $ER_HOSTNAME "sudo /home/ubnt/$BASE_TMPFILE" || fail "Unable to SSH to $ER_HOSTNAME !!"
    echo "Cleaning up temporary file ..."
    rm -f $TMPFILE
else
    echo "Connection is up, exiting ..."
fi

