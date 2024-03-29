#!/usr/bin/env bash
CONFIG_FILE="/root/.pivx/pivx.conf"
url_array=(
    "https://api4.my-ip.io/ip"
    "https://checkip.amazonaws.com"
    "https://api.ipify.org"
)

function get_ip() {
    for url in "$@"; do
        WANIP=$(curl --silent -m 15 "$url" | tr -dc '[:alnum:].')
        # Remove dots from the IP address
        IP_NO_DOTS=$(echo "$WANIP" | tr -d '.')
        # Check if the result is a valid number
        if [[ "$IP_NO_DOTS" != "" && "$IP_NO_DOTS" =~ ^[0-9]+$ ]]; then
            break
        fi
    done
}

if [[ ! -d /root/.pivx-params ]]; then
    cd /usr/local/bin
    bash install-params.sh
    sleep 5
    cd
fi

if [[ ! -f $CONFIG_FILE ]]; then
    get_ip "${url_array[@]}"
    RPCUSER=$(pwgen -1 18 -n)
    PASSWORD=$(pwgen -1 20 -n)
    echo "rpcuser=$RPCUSER" >> $CONFIG_FILE
    echo "rpcpassword=$PASSWORD" >> $CONFIG_FILE
    echo "rpcallowip=127.0.0.1" >> $CONFIG_FILE
    echo "server=1" >> $CONFIG_FILE
    echo "daemon=1" >> $CONFIG_FILE
    echo "masternode=1" >> $CONFIG_FILE
    echo "logtimestamps=1" >> $CONFIG_FILE
    echo "externalip=$WANIP" >> $CONFIG_FILE
    echo "masternodeaddr=$WANIP:51472" >> $CONFIG_FILE
    echo "maxconnections=256" >> $CONFIG_FILE
    echo "masternodeprivkey=$KEY" >> $CONFIG_FILE
fi

if [[ "$KEY" != "" ]]; then 
    if grep -q "^masternodeprivkey=$" $CONFIG_FILE; then
        sed -i "s/^masternodeprivkey=$/masternodeprivkey=$KEY/" $CONFIG_FILE
    fi
fi

while true; do
 if [[ $(pgrep pivxd) == "" ]]; then 
   echo -e "Starting daemon..."
   pivxd -daemon
 fi
 sleep 120
done
