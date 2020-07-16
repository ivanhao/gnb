#!/bin/bash

server="14.18.242.35 58.218.203.5"

GNB_DIR=$(dirname $0)

#GNB_BINARY=FreeBSD_amd64

GNB_BINARY=Linux_x86_64

#GNB_BINARY=macOS
#GNB_BINARY=OpenBSD_amd64

#GNB_BINARY=raspberrypi_ARMv7

#GNB_BINARY=openwrt/ar71xx-generic
#GNB_BINARY=openwrt/ar71xx-mikrotik
#GNB_BINARY=openwrt/ar71xx-nand
#GNB_BINARY=openwrt/mvebu-cortexa9
#GNB_BINARY=openwrt/x86_64
#GNB_BINARY=openwrt/ramips-mt76x8
v6=`sysctl -a|egrep "all.disable_ipv6 = 0$"|wc -l`
if [ $v6 = 0 ];then
    echo "net.ipv6.conf.all.disable_ipv6 = 0" >> /etc/sysctl.conf
    sysctl -p
fi
config(){
    echo "Input node number:"
    read x
    if [[ `echo "$x"|grep "^[0-9]*$"|wc -l` = 0 ]] || [[ $x = "" ]];then
        echo "no content!"
        config
    else
        rm -rf ${GNB_DIR}/conf/*
        for ((i=1;i<=$x;i++))
        do
            mkdir -p ${GNB_DIR}/conf/100$i/ed25519/
            mkdir -p ${GNB_DIR}/conf/100$i/security/
            mkdir -p ${GNB_DIR}/conf/100$i/script/

            cp -r ${GNB_DIR}/conf_tpl/1001/script/* ${GNB_DIR}/conf/100$i/script/


            echo "listen 9001" > ${GNB_DIR}/conf/100$i/node.conf
            echo "nodeid 100$i" >> ${GNB_DIR}/conf/100$i/node.conf

            for k in $server
            do
                echo "i|0|$k|9001" >> ${GNB_DIR}/conf/100$i/address.conf
            done

            ${GNB_DIR}/bin/$GNB_BINARY/gnb_crypto -c -p 100$i.private -k 100$i.public

        done
        for ((i=1;i<=$x;i++))
        do
            for ((j=1;j<=$x;j++))
            do
                echo "100$j|10.10.0.$j|255.255.255.0" >> ${GNB_DIR}/conf/100$i/route.conf
            done
            cp 100*.public ${GNB_DIR}/conf/100$i/ed25519/

            cp 100$i.public 100$i.private ${GNB_DIR}/conf/100$i/security/
        done
        rm *.public *.private
    fi
}
config
