from	ubuntu:12.04
run	echo 'deb http://us.archive.ubuntu.com/ubuntu/ precise universe' >> /etc/apt/sources.list
run	apt-get -y update

run	apt-get -y install python-software-properties &&\
	add-apt-repository ppa:chris-lea/node.js &&\
	apt-get -y update

run     apt-get -y install  python-django-tagging python-simplejson python-memcache \
			    python-ldap python-cairo python-django python-twisted   \
			    python-pysqlite2 python-support python-pip gunicorn     \
			    supervisor nginx-light nodejs git wget curl

# Elastic Search

# fake fuse
run  apt-get install libfuse2 &&\
     cd /tmp ; apt-get download fuse &&\
     cd /tmp ; dpkg-deb -x fuse_* . &&\
     cd /tmp ; dpkg-deb -e fuse_* &&\
     cd /tmp ; rm fuse_*.deb &&\
     cd /tmp ; echo -en '#!/bin/bash\nexit 0\n' > DEBIAN/postinst &&\
     cd /tmp ; dpkg-deb -b . /fuse.deb &&\
     cd /tmp ; dpkg -i /fuse.deb

run    cd ~ && wget https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.0.1.deb
run    cd ~ && dpkg -i elasticsearch-1.0.1.deb && rm elasticsearch-1.0.1.deb
run    apt-get -y install openjdk-7-jre


# Install statsd
run	mkdir /src && git clone https://github.com/etsy/statsd.git /src/statsd

# Install required packages
run	pip install whisper
run	pip install --install-option="--prefix=/var/lib/graphite" --install-option="--install-lib=/var/lib/graphite/lib" carbon
run	pip install --install-option="--prefix=/var/lib/graphite" --install-option="--install-lib=/var/lib/graphite/webapp" graphite-web

# statsd
add	./statsd/config.js /src/statsd/config.js

# Add graphite config
add	./graphite/initial_data.json /var/lib/graphite/webapp/graphite/initial_data.json
add	./graphite/local_settings.py /var/lib/graphite/webapp/graphite/local_settings.py
add	./graphite/carbon.conf /var/lib/graphite/conf/carbon.conf
add	./graphite/storage-schemas.conf /var/lib/graphite/conf/storage-schemas.conf
run	mkdir -p /var/lib/graphite/storage/whisper
run	touch /var/lib/graphite/storage/graphite.db /var/lib/graphite/storage/index
run	chown -R www-data /var/lib/graphite/storage
run	chmod 0775 /var/lib/graphite/storage /var/lib/graphite/storage/whisper
run	chmod 0664 /var/lib/graphite/storage/graphite.db
run	cd /var/lib/graphite/webapp/graphite && python manage.py syncdb --noinput

# graphana
run     mkdir /src/grafana && cd /src/grafana &&\
	wget https://github.com/torkelo/grafana/releases/download/v1.4.0/grafana-1.4.0.tar.gz &&\
	tar -xzvf grafana-1.4.0.tar.gz && rm grafana-1.4.0.tar.gz

add     ./grafana/config.js /src/grafana/config.js

# proxy
add     ./google_auth_proxy/google_auth_proxy /usr/local/bin/google_auth_proxy

# elasticsearch
add	./elasticsearch/run /usr/local/bin/run_elasticsearch



# Add system service config
add	./nginx/nginx.conf /etc/nginx/nginx.conf
add	./supervisord.conf /etc/supervisor/conf.d/supervisord.conf
# Nginx
#
# graphite
expose	85:80
# grafana
expose  86:81

# Carbon line receiver port
expose	2003:2003
# Carbon pickle receiver port
expose	2004:2004
# Carbon cache query port
expose	7002:7002

# Statsd UDP port
expose	8125:8125/udp
# Statsd Management port
expose	8126:8126

cmd	["/usr/bin/supervisord"]

# vim:ts=8:noet:
