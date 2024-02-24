#!/bin/bash

set +e

# This assumes that the user
# Wiedii/Wiedii will run-as
# already exists in the system and can sudo,
# and the current software project
# is copied / placed in the relevant directory with proper
# ownership/permissions.
# This script takes control from there.

# echo $* # DEBUG

PROJECT_ROOT=${1:-`pwd`}
APP_USER=${2:-'wiedii'}

SCRIPTDIR=$PROJECT_ROOT/etc/scripts

export DEBIAN_FRONTEND=noninteractive

install_conffiles() {
    # See README file in doc/sysadm/examples/ .
    install -bvC -m 644 doc/sysadm/examples/etc/dnsmasq.conf            /etc/
    install -bvC -m 644 doc/sysadm/examples/etc/sysctl.conf             /etc/

    install -bvC -m 644 doc/sysadm/examples/etc/usb_modeswitch.conf     /etc/
    install -bvC -m 644 doc/sysadm/examples/etc/usb_modeswitch.d/*:*    /etc/usb_modeswitch.d/
}

disable_dhcpcd_master() {
    # Even if no interface is configured with dhcp in /etc/network/interfaces,
    # dhcpcd is a system(d) service, that starts as just "dhcpcd" (master mode)
    # which is incompatible with wiedii detection and control.
    if (systemctl list-units --all -t service | grep dhcpcd); then
        systemctl stop dhcpcd
        systemctl disable dhcpcd
    fi
}

setup_nginx() {
    apt-get -y remove lighttpd
    apt-get -y install nginx-light ssl-cert
    rm -fv /etc/nginx/sites-enabled/default  # just a symlink
    install -bvC -m 644 doc/sysadm/examples/etc/nginx/sites-available/wiedii /etc/nginx/sites-available/
    ln -svf ../sites-available/wiedii /etc/nginx/sites-enabled/
    systemctl reload nginx
}

cd $PROJECT_ROOT

apt-get update
apt-get -y upgrade

apt-get -y install \
    ruby ruby-dev ruby-rack ruby-rack-protection ruby-locale \
    sudo locales psmisc \
    iproute2 iptables bridge-utils dhcpcd5 dnsmasq resolvconf ifrename ntp \
    openvpn hostapd \
    pciutils usbutils usb-modeswitch \
    build-essential \
    ca-certificates libssl-dev 

install_conffiles

# Let's not use the old Debian one...
gem install -v '~> 2' bundler

su - $APP_USER -c "
    cd $PROJECT_ROOT
    # Module names are also Gemfile groups
    set -x
    bundle install
"

modprobe nf_conntrack
service procps restart

disable_app_modules

disable_dhcpcd_master

# Circumvent this bug:
# http://debian.2.n7.nabble.com/Bug-732920-procps-sysctl-system-fails-to-load-etc-sysctl-conf-td3133311.html
sysctl --load=/etc/sysctl.conf
sysctl --load=$PROJECT_ROOT/doc/sysadm/examples/etc/sysctl.conf

# Disable the legacy persist service: we rely on /etc now...
if ( systemctl list-units --all | grep wiedii-persist.service ); then
    systemctl disable wiedii-persist.service
fi

cat > /etc/systemd/system/wiedii.service <<EOF
[Unit]
Description=Wiedii Service
After=network-online.target

[Service]
Type=simple
User=$APP_USER
WorkingDirectory=$PROJECT_ROOT
Environment="APP_ENV=production"
ExecStart=/usr/bin/env ruby wiedii.rb
SyslogIdentifier=wiedii
Restart=on-failure
# Other Restart options: always, on-abort, on-failure etc
RestartSec=4

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload

systemctl enable wiedii
systemctl start wiedii

cd $PROJECT_ROOT  # Apparently needed...

setup_nginx

# Remove packages conflicting with our DHCP management
if (dpkg -l | egrep '^i.\s+wicd-daemon')
then
    apt-get -y remove wicd-daemon
fi

. $SCRIPTDIR/_restore_dns.sh

