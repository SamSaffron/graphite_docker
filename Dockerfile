from ubuntu:14.04
run	echo 'deb http://us.archive.ubuntu.com/ubuntu/ trusty universe' >> /etc/apt/sources.list
run	apt-get -y update

run	apt-get -y install software-properties-common &&\
	apt-get -y update

RUN apt-get -y update \
  && apt-get -y upgrade \
  && apt-get -y --force-yes install vim \
  nginx \
  python-dev \
  python-flup \
  python-pip \
  python-ldap \
  expect \
  git \
  memcached \
  sqlite3 \
  libffi-dev \
  libcairo2 \
  libcairo2-dev \
  python-cairo \
  python-rrdtool \
  pkg-config \
  nodejs \
  supervisor \
  wget \
  libssl-dev \
  && rm -rf /var/lib/apt/lists/*

RUN pip install gunicorn pyopenssl ndg-httpsclient pyasn1 django==1.8.18 \
  python-memcached==1.53 \
  txAMQP==0.6.2 \
  && pip install --upgrade pip

# Install statsd
run	mkdir /src && git clone https://github.com/etsy/statsd.git /src/statsd

# Install required packages
run	pip install whisper pytz scandir
run	pip install --install-option="--prefix=/var/lib/graphite" --install-option="--install-lib=/var/lib/graphite/lib" carbon
run	pip install --install-option="--prefix=/var/lib/graphite" --install-option="--install-lib=/var/lib/graphite/webapp" graphite-web

# grafana
run     cd ~ &&\
        wget https://s3-us-west-2.amazonaws.com/grafana-releases/release/grafana_4.4.3_amd64.deb &&\
        sudo dpkg -i grafana_4.4.3_amd64.deb &&\
        rm grafana_4.4.3_amd64.deb

# statsd
add	./statsd/config.js /src/statsd/config.js

# Add graphite config
add	./graphite/initial_data.json /var/lib/graphite/webapp/graphite/initial_data.json
add	./graphite/local_settings.py /var/lib/graphite/webapp/graphite/local_settings.py
add	./graphite/carbon.conf /var/lib/graphite/conf/carbon.conf
add	./graphite/storage-schemas.conf /var/lib/graphite/conf/storage-schemas.conf
add	./graphite/storage-aggregation.conf /var/lib/graphite/conf/storage-aggregation.conf

add     ./grafana/config.ini /etc/grafana/config.ini

# Add system service config
add	./nginx/nginx.conf /etc/nginx/nginx.conf
add	./supervisord.conf /etc/supervisor/conf.d/supervisord.conf


# Nginx
#
# graphite
expose	80
# grafana
expose  3000

# Carbon line receiver port
expose	2003
# Carbon UDP receiver port
expose	2003/udp
# Carbon pickle receiver port
expose	2004
# Carbon cache query port
expose	7002

# Statsd UDP port
expose	8125/udp
# Statsd Management port
expose	8126

env STATSD_IPV6 0

# we probably want to do this
# volume /data

add ./bin/init /usr/bin/init

cmd exec /usr/bin/init

