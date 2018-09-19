#!/bin/bash

# eth=`ifconfig -s | sed -n '2p' | cut -d' ' -f 1`
eths=(`ip -o link show |
       grep 'link/ether' |
       grep -iv 'state DOWN' |
       awk '{sub(/:$/, "", $2); print $2}'`)

ne=${#eths[@]}
if [ x$ne == x0 ]
then
    echo "no devices found"
    exit -1
fi

echo -n "$ne link/ethers:"
for e in "${eths[@]}"
do
    echo -n " "$e
done
echo

function all_isdigits() {
    awk -v var="$1" -v yes=yes -v no=no \
        'BEGIN{if(var~/^[+-]?[0-9]+$/) print yes;
               else print no}'
}

eth=${eths[0]}
if [ x$ne != x1 ]
then
    echo "more than one device. Choose one"
    echo -n "input dev name or number [$eth]: "
    read eth
    if [ x"$eth" == x ]; then eth=0; fi

    alld=`all_isdigits "$eth"`
    if [ x"$alld" == xyes ]
    then
        eth=${eths[$eth]}
    fi

    ifconfig "$eth" >/dev/null 2>&1
    if [ $? != 0 ]
    then
        echo "[$eth]: Device not found"
        exit -1
    fi
fi

echo "choose ether link: $eth"

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
echo "begin to turn it on"
sudo ifconfig $tun up
