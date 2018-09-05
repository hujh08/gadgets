#!/bin/bash

eth=`ifconfig -s | sed -n '2p' | cut -d' ' -f 1`

echo "first interfaces: $eth"

ipv4=`ifconfig $eth | sed -n '/inet addr:/s/[^0-9 .]//gp'`
ipv4_addr=`echo $ipv4 | cut -d' ' -f1`

echo "address of $eth: $ipv4_addr"

# setup tunnel
tun=is0
dev=$eth
addr=2402:f000:1:1501:200:5efe:$ipv4_addr
remote=166.111.21.1
route=fe80::5efe:a66f:1501
echo "setup sit tunnel"
echo "    name: [$tun]"
echo "    dev: [$dev]"
echo "    addr: [$addr]"
echo "    remote: [$remote]"
echo "    route:  [$route]"
sudo ip tunnel add $tun mode sit remote $remote dev $dev
sudo ifconfig $tun add $addr
sudo ip route add ::/0 dev $tun via $route metric 1

# turn it on
echo "turn it on"
sudo ifconfig $tun up
