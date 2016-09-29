#!/bin/bash

yum -y update

git clone https://www.github.com/ichthysngs/install /install

cd install/shelldocker-1.0-SNAPSHOT/bin

./shelldocker
