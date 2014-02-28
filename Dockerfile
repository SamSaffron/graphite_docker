# DOCKER-VERSION 0.4.0

from	ubuntu:12.04
run	echo 'deb http://us.archive.ubuntu.com/ubuntu/ precise universe' >> /etc/apt/sources.list
run	apt-get -y update

run	apt-get -y install python-software-properties
run	add-apt-repository ppa:chris-lea/node.js
run	apt-add-repository ppa:brightbox/ruby-ng

run	apt-get -y update
run	apt-get -y install nodejs git ruby rubygems ruby-switch redis-server build-essential
run	gem install bundler

run	mkdir /src

# Install graphiti
run	git clone https://github.com/paperlesspost/graphiti.git /src/graphiti
run	cd /src/graphiti && bundle install --deployment --without 'test development'

# Install statsd
run	git clone https://github.com/etsy/statsd.git /src/statsd

# Install required packages
run	apt-get -y install python-ldap python-cairo python-django python-twisted python-django-tagging python-simplejson python-memcache python-pysqlite2 python-support python-pip gunicorn supervisor nginx-light
run	pip install whisper
run	pip install --install-option="--prefix=/var/lib/graphite" --install-option="--install-lib=/var/lib/graphite/lib" carbon
run	pip install --install-option="--prefix=/var/lib/graphite" --install-option="--install-lib=/var/lib/graphite/webapp" graphite-web

# Add system service config
add	./nginx/nginx.conf /etc/nginx/nginx.conf
add	./supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# statsd
add	./statsd/config.js /src/statsd/config.js

# graphiti
add	./graphiti/unicorn.rb /src/graphiti/config/unicorn.rb
add	./graphiti/settings.yml /src/graphiti/config/settings.yml

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

# Nginx
expose	85:80
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

# unicorn for graphiti
expose 8080:8080

cmd	["/usr/bin/supervisord"]

# vim:ts=8:noet:
