# passivedns stack for Cisco x Aitle 2019

1) Modify the docker-compose.yml file for the network interface you want to monitor
```
services:
  pdns:
    image: ciscoaitle2019/passivedns
    network_mode: "host"
    container_name: pdns
    restart: unless-stopped
    environment:
      INTERFACE: " {{ YOUR NETWORK MONITOR INTERFACE HERE }} "
```

2) Startup the docker-compose stack
```
docker-compose up -d 
```
