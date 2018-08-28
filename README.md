<<<<<<< HEAD
# wireguard
=======
>>>>>>> a1760a1b6f633f7abec9f9a130f4662f7bd75318
## Fast use:

#### Launch container with default options
  
```sh
$ docker run -d --name wg0 --privileged -p 32500:32500 -e OUTPUT=LOG \
  coffeeit/wireguard
# Show QR code for mobile client configuration
$ docker logs wg0
```
---
#### Share to Clients
##### Installing
[Install Wireguard](https://www.wireguard.com/install/)
[App for android](https://play.google.com/store/apps/details?id=com.wireguard.android)


##### Since, to establish a connection using a public and private keys, I see several possibilities for delivering them to the client:
##### 1) Generated configuration file
After launching the container, the < /etc/wireguard/config > directory will already contain all the necessary files to configure the client.
The easiest way to get access is:
```sh
$ docker run -d --name wg0 --privileged \
     -v /your/custom/path:/etc/wireguard/config:rw \
     -p 32500:32500 coffeeit/wireguard
```
##### 2) Output in console
ENV OUTPUT
This method writes into the logs QR codes that can be scanned by the Wireguard application.
I think this is the best solution if you use a VPN from a mobile phone.
```sh
$ docker run -d --name wg0 --privileged \
     -e OUTPUT=LOG \
     -p 32500:32500 coffeeit/wireguard
$ docker logs wg0
```
##### Of course at any time you can use the docker commands to access the required configuration:
```sh
#Server config
docker exec [CONTAINER] cat /etc/wireguard/wg0.conf
#Client config
docker exec [CONTAINER] cat /etc/wireguard/config/client_{№}.conf
```
## Available options and ways to use
###### ENV CLIENTS
Use to specify the number of service users.
By default, the CLIENTS=1 and maximum is limited to 253 on the same network.
```sh
$ docker run -d --name wg0 --privileged -e CLIENTS=7 \
     -p 32500:32500 coffeeit/wireguard
```
###### ENV IP
Use to specify the IP address of the server. This IP will be used by clients to connect. By default, the script will determine your external IP address and use it to clients.
This can be useful if the server is inside the network behind a firewall.
```sh
$ docker run -d --name wg0 --privileged -e IP=192.168.1.1 \
     -p 32500:32500 coffeeit/wireguard
```

###### ENV PORT
Use to specify the PORT of the server. This parameter will be used by clients to connect. This port will also be listened to by the server. By default used PORT 32500. 
This is useful when you are using a key --network host
```sh
$ docker run -d --name wg0 --privileged -e PORT=55555 coffeeit/wireguard
```
You can also use the standard Docker functionality:
```sh
$ docker run -d --name wg0 --privileged -e IP=192.168.1.1 \ 
     -p 55555:32500 coffeeit/wireguard
```

### Start the container automatically
If you want to use this container as part of your permanent infrastructure, you should set it to restart automatically when Docker restarts or if it exits. This example uses the --restart=always flag to set a restart policy for the container.
### All recomened options in line:
*
| Start container "wg0" in background in privileged mode |
```sh
$ docker run -d --name wg0 --privileged \ 
```
*
| - Set server IP for clients - | - and server port - | - for 7 VPN users - | - I'll take conf from console - |
```sh
$ -e IP=192.168.1.1 -e PORT=55555 -e CLIENTS=7 -e OUTPUT=LOG \ 
```
*
| ------------ mount the configuration directory ------------ |
```sh
$ -v /your/custom/path:/etc/wireguard/config:rw  \
```
*
| -- publish port -- | --- image --|
```sh
$ -p 55555:32500 coffeeit/wireguard
```
### In plans:
* Client setup
* add / remove users without full cleaning
* More users on the same subnet
