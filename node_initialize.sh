#!/usr/bin/env bash

function get_ip() {

    WANIP=$(curl --silent -m 15 https://api4.my-ip.io/ip | tr -dc '[:alnum:].')

    if [[ "$WANIP" == "" ]]; then
      WANIP=$(curl --silent -m 15 https://checkip.amazonaws.com | tr -dc '[:alnum:].')
    fi

    if [[ "$WANIP" == "" ]]; then
      WANIP=$(curl --silent -m 15 https://api.ipify.org | tr -dc '[:alnum:].')
    fi
}

if [[ ! -d /root/.pivx-params ]]; then
cd /tmp/pivx-5.3.2.1
bash install-params.sh
cd
sleep 10
fi

get_ip
RPCUSER=$(pwgen -1 8 -n)
PASSWORD=$(pwgen -1 20 -n)

if [[ -f /root/.pivx/pivx.conf ]]; then
  rm  /root/.pivx/pivx.conf
fi

touch /root/.pivx/pivx.conf
cat << EOF > /root/.pivx/pivx.conf
rpcuser=$RPCUSER
rpcpassword=$PASSWORD
rpcallowip=127.0.0.1
server=1
daemon=1
masternode=1
externalip=$WANIP
masternodeaddr=$WANIP:51472
masternodeprivkey=$KEY
maxconnections=256
EOF

while true; do
pivxd
sleep 60
done
