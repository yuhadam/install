#!/bin/bash

yum -y update

wget -no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u60-b27/jdk-8u60-linux-x64.rpm"

yum localinstall jre-8u60-linux-x64.rpm


git clone https://www.github.com/ichthysngs/install /install

cd /install/shelldocker-1.0-SNAPSHOT/bin

./shelldocker
