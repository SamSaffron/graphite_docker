FROM ubuntu:14.04
RUN	echo 'deb http://us.archive.ubuntu.com/ubuntu/ trusty universe' >> /etc/apt/sources.list && \
	apt-get -y update && \
	apt-get -y install software-properties-common && \
	apt-get -y update && \
  	apt-get -y upgrade && \
  	apt-get -y --force-yes install vim \
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
# Install required packages
RUN	mkdir /src && git clone https://github.com/etsy/statsd.git /src/statsd && \
	pip install whisper pytz scandir && \
	pip install --install-option="--prefix=/var/lib/graphite" --install-option="--install-lib=/var/lib/graphite/lib" carbon && \
	pip install --install-option="--prefix=/var/lib/graphite" --install-option="--install-lib=/var/lib/graphite/webapp" graphite-web

# grafana
RUN cd ~ &&\
	wget https://s3-us-west-2.amazonaws.com/grafana-releases/release/grafana_4.4.3_amd64.deb &&\
	sudo dpkg -i grafana_4.4.3_amd64.deb &&\
	rm grafana_4.4.3_amd64.deb

# statsd
ADD	./statsd/config.js /src/statsd/config.js

# ADD graphite config
ADD	./graphite/initial_data.json /var/lib/graphite/webapp/graphite/initial_data.json
ADD	./graphite/local_settings.py /var/lib/graphite/webapp/graphite/local_settings.py
ADD	./graphite/carbon.conf /var/lib/graphite/conf/carbon.conf
ADD	./graphite/storage-schemas.conf /var/lib/graphite/conf/storage-schemas.conf
ADD	./graphite/storage-aggregation.conf /var/lib/graphite/conf/storage-aggregation.conf

ADD ./grafana/config.ini /etc/grafana/config.ini

# ADD system service config
ADD	./nginx/nginx.conf /etc/nginx/nginx.conf
ADD	./supervisord.conf /etc/supervisor/conf.d/supervisord.conf


# Nginx
#
# graphite | grafana | Carbon line receiver port | Carbon UDP receiver port | Carbon pickle receiver port | Carbon cache query port | Statsd UDP port | Statsd Management port
EXPOSE	80 3000 2003 2003/udp 2004 7002 8125/udp 8126

ENV STATSD_IPV6 0

# we probably want to do this
# volume /data

ADD ./bin/init /usr/bin/init

CMD exec /usr/bin/init

