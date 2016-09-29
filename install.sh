#!/bin/bash

yum -y update

cat > /etc/yum.repos.d/docker.repo << '__EOF__'

[dockerrepo]
name=Docker Repository
baseurl=https://yum.dockerproject.org/repo/main/centos/7/
enabled=1
gpgcheck=1
gpgkey=https://yum.dockerproject.org/gpg
__EOF__

cat > /etc/modules-load.d/overlay.conf << '__EOF__'
overlay
__EOF__

mkdir -p /etc/systemd/system/docker.service.d

cat > /etc/systemd/system/docker.service.d/override.conf << '__EOF__'
[Service]
ExecStart=
ExecStart=/usr/bin/docker daemon --storage-driver=overlay -H fd://
__EOF__


yum install -y docker-engine-1.11.2
yum install -y yum-versionlock
yum versionlock docker-engine

yum clean all

systemctl daemon-reload
systemctl start docker
systemctl enable docker
yum -y update

docker run -p 9000:9000 --name installserver ichthysngs/installserver
