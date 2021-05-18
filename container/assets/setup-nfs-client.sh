#!/bin/ash

set -x

PLATFORM_NAME="unknown"
ROOT="/noderoot"

mount --bind /etc/resolv.conf "${ROOT}/etc/resolv.conf"

function install_ubuntu() {
    EXISTS=$(chroot "$ROOT" dpkg -l nfs-common | grep -c "^i")
    if [ "$EXISTS" == "0" ]; then
        chroot "$ROOT" apt update
        chroot "$ROOT" apt install -y nfs-common
        chroot "$ROOT" apt clean
    fi
}

function install_centos_redhat() {
  EXISTS=$(chroot "$ROOT" rpm -qa nfs-utils | wc -l)
  if [ "$EXISTS" == "0" ]; then
      chroot "$ROOT" yum update
      chroot "$ROOT" yum install -y nfs-utils
      chroot "$ROOT" yum clean all
  fi
}

#
# Mainline
#
if [ -f $ROOT/etc/lsb-release ]; then
  # this file exists on debian and ubuntu
  PLATFORM_NAME="UBUNTU"
fi
if [ -f $ROOT/etc/redhat-release ]; then
  # this file exists on centos and redhat
  PLATFORM_NAME="REDHAT"
fi
if [ -f $ROOT/etc/centos-release ]; then
  # this file will exist on centos, but not on redhat
  PLATFORM_NAME="CENTOS"
fi

echo "Discovered system type: ${PLATFORM_NAME}"
if [ "${PLATFORM_NAME}" == "unknown" ]; then
  echo "Cannot install the PowerFlex on a system of unknown type"
  exit 1
fi

if [ "${PLATFORM_NAME}" == "REDHAT" ] || [ "${PLATFORM_NAME}" == "CENTOS" ]; then
  install_centos_redhat
fi

# UBUNTU
if [ "${PLATFORM_NAME}" == "UBUNTU" ]; then
  install_ubuntu
fi