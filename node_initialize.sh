#!/usr/bin/env bash

function get_ip() {
    WANIP=$(curl --silent -m 15 https://api4.my-ip.io/ip | tr -dc '[:alnum:].')
    if [[ "$WANIP" == "" || "$WANIP" = *htmlhead* ]]; then
        WANIP=$(curl --silent -m 15 https://checkip.amazonaws.com | tr -dc '[:alnum:].')    
    fi  
    if [[ "$WANIP" == "" || "$WANIP" = *htmlhead* ]]; then
        WANIP=$(curl --silent -m 15 https://api.ipify.org | tr -dc '[:alnum:].')
    fi
}

get_ip
RPCUSER=$(pwgen -1 18 -n)
PASSWORD=$(pwgen -1 20 -n)

if [[ ! -d /root/.pivx-params ]]; then
  cd /usr/local/bin
  bash install-params.sh
  sleep 5
  cd
fi

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
logtimestamps=1
externalip=$WANIP
masternodeaddr=$WANIP:51472
masternodeprivkey=$KEY
maxconnections=256
EOF

while true; do
 if [[ $(pgrep pivxd) == "" ]]; then 
   echo -e "Starting daemon..."
   pivxd -daemon
 fi
 sleep 120
done
