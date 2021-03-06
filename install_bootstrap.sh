#!/bin/bash

index=0

for var in "$@"
do
array[$index]="$var"
((index+=1))
done

num=2
portNum=${array[$num]}

masterIpNum=1
masterip="${array[3]}"
arrlen=${#array[@]}



yum -y update
yum install -y vim
yum install -y net-tools
yum install -y wget

echo -e "\n" | ssh-keygen -t rsa -N ""
#wget http://apt.sw.be/redhat/el7/en/x86_64/rpmforge/RPMS/sshpass-1.05-1.el7.rf.x86_64.rpm

rpm -Uvh /install/sshpass-1.05-1.el7.rf.x86_64.rpm

for((i=3;i<$arrlen; i++))
do
sshpass -p "${array[1]}" ssh-copy-id -o StrictHostKeyChecking=no root@${array[$i]}
done

for((i=3;i<$arrlen;i++))
do
ssh root@${array[$i]} "yum -y update && yum install -y git && cd /root/ && git clone http://www.github.com/ichthysngs/install2 && cd install2 && ./install_nobootstrap.sh"
echo "#####finish#####"
done



cat > /etc/yum.repos.d/docker.repo << '__EOF__'

[dockerrepo]
name=Docker Repository
baseurl=https://yum.dockerproject.org/repo/main/centos/7/
enabled=1
gpgcheck=1
gpgkey=https://yum.dockerproject.org/gpg
__EOF__

#cat > /etc/modules-load.d/overlay.conf << '__EOF__'
#overlay
#__EOF__

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

yum install -y tar xz unzip curl ipset nfs-utils
yum clean all

groupadd nogroup
yum -y update




yum install -y ntp


sed -i '21,24d' /etc/ntp.conf

sed -i '21s/$/server 0.kr.pool.ntp.org\n/' /etc/ntp.conf
sed -i '22s/$/server 1.asia.pool.ntp.org\n/' /etc/ntp.conf
sed -i '23s/$/server 3.asia.pool.ntp.org\n/' /etc/ntp.conf

systemctl start ntpd
systemctl enable ntpd


mkdir /dcos
chmod 777 /dcos
mkdir -p /dcos/genconf
cd /dcos
curl -O https://downloads.dcos.io/dcos/EarlyAccess/commit/14509fe1e7899f439527fb39867194c7a425c771/dcos_generate_config.sh
cd genconf

echo "---" >> config.yaml
echo "agent_list:" >> config.yaml

for(( i=3+$masterIpNum; i<$arrlen; i++))
do
echo "- ${array[$i]}" >> config.yaml
done

cat >> config.yaml << "EOF"
bootstrap_url: 'file:///opt/dcos_install_tmp'
cluster_name: dcos
exhibitor_storage_backend: static
master_discovery: static
master_list:
EOF

for(( i=3; i<3+$masterIpNum; i++))
do
echo "- ${array[$i]}" >> config.yaml
done



cat >> config.yaml << "EOF"
resolvers:
- 8.8.4.4
- 8.8.8.8
ssh_key_path: /genconf/ssh_key
EOF

echo "ssh_port: $portNum" >> config.yaml
echo "ssh_user: root" >> config.yaml
echo "oauth_enabled: 'false'" >> config.yaml


echo "#!/bin/bash" >> ip-detect
echo "set -o nounset -o errexit" >> ip-detect
echo "export PATH=/usr/sbin:/usr/bin:\$PATH" >> ip-detect
echo "echo \$(ip addr show ${array[0]} | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)" >> ip-detect


chmod 777 ip-detect config.yaml
cp /root/.ssh/id_rsa /dcos/genconf/ssh_key && chmod 0600 /dcos/genconf/ssh_key

cd /dcos/
bash dcos_generate_config.sh --genconf
bash dcos_generate_config.sh --install-prereqs
bash dcos_generate_config.sh --preflight
bash dcos_generate_config.sh --deploy
bash dcos_generate_config.sh --postflight && wait

#cd /install
#./install_bootstrap22.sh ${array[0]} ${array[1]} ${array[2]} ${array[3]} ${array[4]} ${array[5]}

: << 'END'

mkdir dcosclidir && cd dcosclidir
curl -O https://downloads.dcos.io/binaries/cli/linux/x86-64/dcos-1.8/dcos
chmod +x dcos
./dcos config set core.dcos_url http://${array[3]}
./dcos auth login
echo "yes" | ./dcos package install chronos

sleep 30s

TEMP=$(./dcos marathon task list --json | grep -n "port" | grep -Eo '[0-9]{1,2}')

PORT_LINE=$(($TEMP+1))
ENDPOINT_PORT=$(./dcos marathon task list --json | sed "$PORT_LINE,$PORT_LINE!d" | sed 's/ //g')
ENDPOINT_IP=$(./dcos service | grep chronos | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)
END

ssh -T root@$masterip << EOSSH
sed -i "s/ip/$masterip/g" /etc/systemd/system/docker.service.d/override.conf
systemctl daemon-reload
systemctl restart docker
docker run --restart=on-failure:10 -d -p 5000:5000 -e standalone=True -e disable_token_auth=True -v /tmp/registry/:/var/lib/registry/ --name registry registry:2

#git clone http://www.github.com/ichthysngs/installserver
#cd installserver
#yum install -y sqlite sqlite-devel
#sqlite3 ichthys.db "insert into user values(0,'admin','$masterip','');"
#modprobe nfs
#modprobe nfsd
#service rpcbind stop
#docker build --tag ichthysngs .
#./start.sh
#cd /root
#rm -rf installserver
EOSSH

for(( i=3+$masterIpNum; i<$index; i++))
do
ssh -T root@${array[$i]} << EOSSH
sed -i "s/ip/$masterip/g" /etc/systemd/system/docker.service.d/override.conf
systemctl daemon-reload 
systemctl restart docker
#mkdir -p /nfsdir
#chmod 777 /nfsdir
#mount -t nfs $masterip:/nfsdir /nfsdir
exit
EOSSH
done


sleep 10s

cd /install/

sed -i "7s/$/--http_notification_url http:\/\/$masterip:9001\/fail\",/g" /install/chronos.json && wait
curl -L -H 'Content-Type: application/json' -X POST -d @chronos.json http://$masterip:8080/v2/apps && wait
sleep 10s


echo "##############################################################################"
echo "###############            all finished              #########################"
echo "##############################################################################"



