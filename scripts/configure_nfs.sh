#!/bin/bash
chmod -R g+rws /opt/
chmod -R o+rw /opt/
apt-get install nfs-kernel-server -y
echo "/opt/ *(rw,no_subtree_check)" >> /etc/exports
service nfs-kernel-server restart
