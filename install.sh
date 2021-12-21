#!/bin/bash
apt update -y
apt install -y --no-install-recommends cron wget
wget --no-check-certificate -O /root/percona-xtrabackup-24_2.4.24-1.focal_amd64.deb https://downloads.percona.com/downloads/Percona-XtraBackup-2.4/Percona-XtraBackup-2.4.24/binary/debian/focal/x86_64/percona-xtrabackup-24_2.4.24-1.focal_amd64.deb
dpkg -i /root/percona-xtrabackup-24_2.4.24-1.focal_amd64.deb
apt install -fy
apt clean
rm -rf /var/log/*
rm -rf /var/lib/apt/lists/*
rm -rf /root/percona-xtrabackup-24_2.4.24-1.focal_amd64.deb
