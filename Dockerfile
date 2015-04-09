from	ubuntu:14.04
run	echo 'deb http://us.archive.ubuntu.com/ubuntu/ trusty universe' >> /etc/apt/sources.list
run	apt-get -y update

run	apt-get -y install software-properties-common &&\
	add-apt-repository ppa:chris-lea/node.js &&\
	apt-get -y update

run     apt-get -y install  python-django-tagging python-simplejson python-memcache \
			    python-ldap python-cairo python-django python-twisted   \
			    python-pysqlite2 python-support python-pip gunicorn     \
			    supervisor nginx-light nodejs git wget curl

# Install statsd
run	mkdir /src && git clone https://github.com/etsy/statsd.git /src/statsd

# Install required packages
run	pip install whisper
run	pip install --install-option="--prefix=/var/lib/graphite" --install-option="--install-lib=/var/lib/graphite/lib" carbon
run	pip install --install-option="--prefix=/var/lib/graphite" --install-option="--install-lib=/var/lib/graphite/webapp" graphite-web

# graphana
run     cd ~ &&\
	wget https://grafanarel.s3.amazonaws.com/builds/grafana_2.0.0-beta1_amd64.deb &&\
        dpkg -i grafana_2.0.0-beta1_amd64.deb && rm grafana_2.0.0-beta1_amd64.deb

# statsd
add	./statsd/config.js /src/statsd/config.js

# Add graphite config
add	./graphite/initial_data.json /var/lib/graphite/webapp/graphite/initial_data.json
add	./graphite/local_settings.py /var/lib/graphite/webapp/graphite/local_settings.py
add	./graphite/carbon.conf /var/lib/graphite/conf/carbon.conf
add	./graphite/storage-schemas.conf /var/lib/graphite/conf/storage-schemas.conf

run	mkdir -p /data/graphite/whisper
run	touch /data/graphite/graphite.db /data/graphite/index
run	chown -R www-data /data/graphite
run	chmod 0775 /data/graphite /data/graphite/whisper
run	chmod 0664 /data/graphite/graphite.db
run	cd /var/lib/graphite/webapp/graphite && python manage.py syncdb --noinput


add     ./grafana/config.ini /etc/grafana/config.ini

# proxy
add     ./google_auth_proxy/google_auth_proxy /usr/local/bin/google_auth_proxy


# Add system service config
add	./nginx/nginx.conf /etc/nginx/nginx.conf
add	./supervisord.conf /etc/supervisor/conf.d/supervisord.conf
# Nginx
#
# graphite
expose	85:80
# grafana
expose  3000:81

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

add ./graphite/create_graphite_db /usr/bin/create_graphite_db
add ./grafana/ensure_grafana_db /usr/bin/ensure_grafana_db

cmd	/usr/bin/ensure_grafana_db && /usr/bin/create_graphite_db && /usr/bin/supervisord
