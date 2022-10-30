#!/bin/bash

ONBOARD_USER=onboard
ONBOARD_GROUP=$ONBOARD_USER
ONBOARD_ROOT=/home/$ONBOARD_USER/onboard
ONBOARD_GIT="https://github.com/vemarsas/onboard.git"

install_conffiles() {
	cd $ONBOARD_ROOT
	cd doc/sysadm/examples
	install -bvC -m 440 etc/sudoers			/etc/
}

setup_core() {
  echo " Installing core and OpenVPN functionality..."

  apt-get update
  apt-get -y upgrade
  apt-get -y install sudo git-core openssh-server curl vim-nox mc

  adduser --system --shell /bin/bash --group $ONBOARD_USER && \
        echo "$ONBOARD_USER:$ONBOARD_USER" | chpasswd

  su - $ONBOARD_USER -c "
  if [ -d onboard ]; then
    cd onboard
    git remote set-url origin $ONBOARD_GIT
    git pull --ff-only origin margay || true
  else
    git clone -b margay $ONBOARD_GIT
    # HTTPS passwords have been disabled by GitHub, allow at least to store tokens...
    git config --global credential.helper store
  fi
  "

  install_conffiles # including sudoers

  cd $ONBOARD_ROOT

  bash etc/scripts/platform/debian/setup.sh $ONBOARD_ROOT $ONBOARD_USER

  bash modules/openvpn/etc/scripts/platform/debian/setup.sh $ONBOARD_ROOT $ONBOARD_USER

  # Raspbian section

  # Disable pi user, with its insecure default password...
  if id -u pi 2> /dev/null; then # DO not show missing user error here...
    echo "Would you like to disable pi user? (y/n)"
    read answer
    if [[ $answer == y ]] ; then
      if id -u $ONBOARD_USER > /dev/null; then # ...but so show it here!
        echo 'Disabling/locking user "pi" (Raspberry) for security reasons.'
        echo "We have the user '$ONBOARD_USER' instead."
        passwd -l pi
      fi
    else
      echo "Change default password for security reasons"
      sudo passwd pi
    fi
    #clone groups from pi to ONBOARD_USER
    SRC=pi
    DEST=$ONBOARD_USER
    SRC_GROUPS=$(groups ${SRC})
    NEW_GROUPS=""
    i=0
    for gr in $SRC_GROUPS
      do
        if [ $i -gt 2 ]
        then
          if [ -z "$NEW_GROUPS" ];
          then NEW_GROUPS=$gr;
          else NEW_GROUPS="$NEW_GROUPS,$gr"; adduser $ONBOARD_USER $gr;
          fi
        fi
        (( i++ ))
      done
    echo "User $ONBOARD_USER added to the following groups: $NEW_GROUPS"
  fi

  # Apparently not enabled by default on Raspbian
  # TODO: make it optional in order to be security-paranoid?
  systemctl start ssh
  systemctl enable ssh
}

setup_ap() {
  echo " Installing Wireless Access Point functionality..."
  cd $ONBOARD_ROOT
  bash modules/ap/etc/scripts/platform/debian/setup.sh $ONBOARD_ROOT $ONBOARD_USER
}

setup_hotspot() {
  echo " Installing Hotspot/RADIUS functionality..."
  cd $ONBOARD_ROOT
  bash modules/radius-admin/etc/scripts/platform/debian/setup.sh $ONBOARD_ROOT $ONBOARD_USER
}

setup_virt() {
  echo " Installing Virtualization functionality..."
  cd $ONBOARD_ROOT
  bash modules/qemu/etc/scripts/platform/debian/setup.sh $ONBOARD_ROOT $ONBOARD_USER
}

run_interactive() {
  # Contributed by <marco.piscopia@vemarsas.it>

  clear
  echo 'Select one or more between following options:'
  echo
  echo '0) Default = core and openvpn functionality'
  echo '1) Hotspot/RADIUS functionality'
  echo '2) Virtualization functionality'
  echo '3) Wireless Access Point functionality'
  echo
  echo 'Eg.Usage:   0 2 3   [Enter]'
  echo
  echo -n 'Options: '
  read opt1 opt2 opt3 opt4
  opt=($opt1 $opt2 $opt3 $opt4)

  for op in "${opt[@]}"; do
    case "$op" in
    0)
      setup_core | tee -a /var/log/mgyinstall.log
      ;;
    1)
      setup_hotspot | tee -a /var/log/mgyinstall.log
      ;;
    2)
      setup_virt | tee -a /var/log/mgyinstall.log
      ;;
    3)
      setup_ap | tee -a /var/log/mgyinstall.log
      ;;
    *)
      echo " Option not provided"
      ;;
    esac
  done
}

run_interactive
