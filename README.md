## Graphite + Carbon + Statsd + Grafana

An all-in-one image running graphite and carbon-cache.

This image contains a sensible default configuration of graphite,
carbon-cache and grafana. Starting this container will expose following ports:

- `80`: the graphite web interface
- `3000`: the grafana web interface
- `2003`: the carbon-cache line receiver (the standard graphite protocol)
- `2004`: the carbon-cache pickle receiver
- `7002`: the carbon-cache query port (used by the web interface)
- `8125`: the statsd UDP port
- `8126`: the statsd management port


You can log into the administrative interface of graphite-web (a Django
application) with the username `admin` and password `admin`. These passwords can
be changed through the web interface.

**NB**: Please be aware that by default docker will make the exposed ports
accessible from anywhere if the host firewall is unconfigured.

### Data volumes

All data is stored in the /data folder in the container (graphite metrics and grafana db)


    docker run -v /data/graphite:/data \
               -e SECRET_KEY='random-secret-key' \
               -p 80:80 \
               -p 3000:3000 \
               -p 2003:2003 \
               -p 2004:2004 \
               -p 7002:7002 \
               -p 8125:8125/udp \
               -p 8126:8126 \
               -d samsaffron/graphite

### Technical details

By default, this instance of carbon-cache uses the following retention periods
resulting in whisper files of approximately 2.5MiB.

    10s:8d,1m:31d,10m:1y,1h:5y

### ENV vars

Use `STATSD_IPV6=1` to boot statsd with IPv6 support, by default it only binds to IPv4

### Getting started

Generate your SECRET_KEY from [here](http://www.miniwebtool.com/django-secret-key-generator/). It is optional but highly recommended.


### Based off

https://github.com/nickstenning/dockerfiles.git

Extended by Sam Saffron
