#!/bin/ash

# this script will exit up any failure which signifies an error to the caller
set -e
set -x

ROOT="/noderoot"

INSTALLED=$(chroot "${ROOT}" /sbin/mount.nfs -V | wc -l)
if [ "$INSTALLED" == "0" ]; then
    exit 1
fi