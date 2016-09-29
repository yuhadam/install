#!/bin/bash

yum -y update

wget --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u102-b14/jdk-8u102-linux-x64.rpm

yum localinstall jdk-8u102-linux-x64.rpm

wget http://downloads.typesafe.com/scala/2.11.6/scala-2.11.6.rpm

rpm -ivh /data/scala-2.11.6.rpm

git clone https://www.github.com/ichthysngs/install /install

cd /install/shelldocker-1.0-SNAPSHOT/bin

./shelldocker
