#!/bin/sh

START_SERVER(){
wg-quick up wg0
}

CREATE_SERVER() {
mainprivkey=""
mainpubkey=""
cltpubkey=""
cltprivkey=""
howmuch=""
extip=""
extport=""
wgstatus=""
direxist=""

if [ -z "$IP" ] && [ -z "$PORT" ] && [ -z "$CLIENTS" ]; then
	extip=$(wget -qO- http://ifconfig.co)
	extport="32500"
	howmuch="1"
else
	if [ -z "$IP" ]; then
		extip=$(wget -qO- http://ifconfig.co)
	else
		extip=$IP
	fi

	if [ -z "$PORT" ]; then
		extport="32500"
	elif [ "$PORT" -gt "1024" ] && [ "$PORT" -le "65535" ]; then
		extport=$PORT
	else
		extport="32500"
	fi


	if [ -z "$CLIENTS" ]; then
		howmuch="1"
	elif [ "$CLIENTS" -gt "1" ] && [ "$CLIENTS" -le "253" ]; then
		howmuch=$CLIENTS
	else
		howmuch="1"
	fi
fi

wg genkey | tee /etc/wireguard/server_private_key | wg pubkey > /etc/wireguard/server_public_key
mainprivkey=$(cat /etc/wireguard/server_private_key)
mainpubkey=$(cat /etc/wireguard/server_public_key)

cat <<EOF > /etc/wireguard/wg0.conf
[Interface]
Address = 10.10.200.254/24
PrivateKey = $mainprivkey
ListenPort = $extport
EOF

if ! [ -d /etc/wireguard/config ]; then
	mkdir /etc/wireguard/config
fi
i=1
while [ "$i" -le "$howmuch" ];
	do
        wg genkey | tee /etc/wireguard/client_"$i"_privkey | wg pubkey > /etc/wireguard/client_"$i"_pubkey
        cltpubkey=$(cat /etc/wireguard/client_"$i"_pubkey)
        cltprivkey=$(cat /etc/wireguard/client_"$i"_privkey)

        cat <<EOF >> /etc/wireguard/wg0.conf
[Peer]
PublicKey = $cltpubkey
AllowedIPs = 10.10.200.$i/32
EOF

        cat <<EOF > /etc/wireguard/client_"$i".conf
[Interface]
Address = 10.10.200.$i/24
PrivateKey = $cltprivkey
DNS = 8.8.8.8
[Peer]
PublicKey = $mainpubkey
Endpoint = $extip:$extport
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 21
EOF

	cp /etc/wireguard/client_"$i".conf /etc/wireguard/config/client_"$i".conf
	if [ "$OUTPUT" = "LOG" ]; then
		echo "================================CLIENT $i================================="
		qrencode -t ANSIUTF8 < /etc/wireguard/config/client_"$i".conf
		echo "=========================================================================="
		qrencode -o /etc/wireguard/config/client_"$i".png < /etc/wireguard/config/client_"$i".conf
	else
		qrencode -o /etc/wireguard/config/client_"$i".png < /etc/wireguard/config/client_"$i".conf
	fi
        i=$(($i + 1))
done
wgstatus=$(wg | grep wg0)
if [ -n "$wgstatus" ]; then
	wg-quick down wg0
fi
wg-quick up wg0
}

CLIENT(){
	confext=".conf"
	WGPATH="/etc/wireguard/"
	echo "I'm a Client"
	echo "My conf is $1"
	if [ -f "$WGPATH$1$confext" ]; thendoc
		wg-quick up $1
	else
		echo "File not found!"
	fi
	
}
case $1 in
	"SERVER"	) 
		[ -f "/etc/wireguard/wg0.conf" ] && START_SERVER || CREATE_SERVER;;
	"CLIENT"	) CLIENT $2
esac
