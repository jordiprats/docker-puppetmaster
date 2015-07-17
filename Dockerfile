FROM ubuntu:14.04
MAINTAINER Jordi Prats


# timezone and locale
RUN echo "Europe/Andorra" > /etc/timezone && \
	dpkg-reconfigure -f noninteractive tzdata
RUN export LANGUAGE=en_US.UTF-8 && \
	export LANG=en_US.UTF-8 && \
	export LC_ALL=en_US.UTF-8 && \
	locale-gen en_US.UTF-8 && \
	DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales

RUN DEBIAN_FRONTEND=noninteractive apt-get install wget -y

RUN wget http://apt.puppetlabs.com/puppetlabs-release-wheezy.deb

RUN dpkg -i puppetlabs-release-wheezy.deb

RUN DEBIAN_FRONTEND=noninteractive apt-get update

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y puppet puppet-common puppet-el puppet-testsuite puppetmaster puppetmaster-common vim-puppet puppetmaster-passenger

RUN sed -i "s/START=yes/START=no/g" /etc/default/puppetmaster

ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_PID_FILE /var/run/apache2/apache2.pid
ENV APACHE_RUN_DIR /var/run/apache2
ENV APACHE_RUN_GROUP www-data
ENV APACHE_RUN_USER www-data

#TODO: eliminar logs d'apache

ENTRYPOINT ["/usr/sbin/apache2", "-k", "start", "-DNO_DETACH"]
