FROM debian:9.5
LABEL maintainer="sergei@coffee-it.org"

RUN echo "deb http://deb.debian.org/debian/ unstable main" > /etc/apt/sources.list.d/unstable.list \ 
	&& printf 'Package: *\nPin: release a=unstable\nPin-Priority: 150\n' > /etc/apt/preferences.d/limit-unstable \
	&& apt update && apt install -y wireguard wget iptables qrencode \
	&& rm -rf /var/cache/apt/* \
	&& mkdir /etc/wireguard/config

ENV ROLE="SERVER"
ENV NAME=""
ENV IP=""
ENV PORT="32500"
ENV CLIENTS=""
ENV OUTPUT=FILE

COPY "autostart.sh" /home

CMD iface=$(ip r | grep default | awk -Fdev '{print $2}' | awk -F " " '{print $1}') \
	&& iptables -t nat -A POSTROUTING -o $iface -j MASQUERADE \
	&& echo "${ROLE} ${NAME}" && sh /home/autostart.sh ${ROLE} ${NAME} \
	&& wg-quick up wg0 \
	&& tail -f /dev/stdout

