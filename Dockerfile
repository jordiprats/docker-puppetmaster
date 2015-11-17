FROM ubuntu:14.04
MAINTAINER Jordi Prats

ENV EYP_PUPPETFQDN=puppet2
ENV EYP_PUPPET_INSTANCE_MODULES=/etc/instance-puppet-modules
ENV EYP_INTERNAL_FORGE http://localhost:80
ENV HOME /root

RUN mkdir -p /usr/local/src
RUN mkdir -p /etc/puppet
RUN [ "/bin/bash", "-c", "mkdir -p $EYP_PUPPET_INSTANCE_MODULES" ]

COPY runme.sh /usr/local/bin/

#
# timezone and locale
#
RUN echo "Europe/Andorra" > /etc/timezone && \
	dpkg-reconfigure -f noninteractive tzdata

RUN export LANGUAGE=en_US.UTF-8 && \
	export LANG=en_US.UTF-8 && \
	export LC_ALL=en_US.UTF-8 && \
	locale-gen en_US.UTF-8 && \
	DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales

RUN DEBIAN_FRONTEND=noninteractive apt-get update

RUN DEBIAN_FRONTEND=noninteractive apt-get install wget -y

#
# puppet repo
#
RUN wget http://apt.puppetlabs.com/puppetlabs-release-wheezy.deb >/dev/null 2>&1
RUN dpkg -i puppetlabs-release-wheezy.deb
RUN DEBIAN_FRONTEND=noninteractive apt-get update

#
# puppet packages
#
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y puppet puppet-common puppet-el puppet-testsuite puppetmaster puppetmaster-common vim-puppet puppetmaster-passenger

#
# disable puppetmaster daemon (we are using passenger)
#
RUN sed -i "s/START=yes/START=no/g" /etc/default/puppetmaster

#
# puppet config
#
RUN mkdir -p /etc/puppet

RUN sed 's@SSLCertificateFile.*@SSLCertificateFile /var/lib/puppet/ssl/certs/puppet.pem@' -i /etc/apache2/sites-available/puppetmaster.conf
RUN sed 's@SSLCertificateKeyFile.*@SSLCertificateKeyFile /var/lib/puppet/ssl/private_keys/puppet.pem@' -i /etc/apache2/sites-available/puppetmaster.conf


# eliminar logs d'apache
RUN find /etc/apache2 -iname \*conf -exec  sed 's@\(ErrorLog \).*@\1 /dev/null@' -i {} \;
RUN find /etc/apache2 -iname \*conf -exec  sed 's@CustomLog .*@@' -i {} \;

#clone eyp-puppet
RUN mkdir -p /usr/local/src/puppetmodules

RUN git clone https://github.com/jordiprats/eyp-puppet /usr/local/src/puppetmodules/puppet
RUN git clone https://github.com/puppetlabs/puppetlabs-stdlib /usr/local/src/puppetmodules/stdlib
RUN git clone https://github.com/puppetlabs/puppetlabs-concat /usr/local/src/puppetmodules/concat

#
# apache vars
#
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_PID_FILE /var/run/apache2/apache2.pid
ENV APACHE_RUN_DIR /var/run/apache2
ENV APACHE_RUN_GROUP www-data
ENV APACHE_RUN_USER www-data

VOLUME ["/var/lib/puppet"]
VOLUME ["/etc/puppet"]


EXPOSE 8140

#ENTRYPOINT ["/usr/sbin/apache2", "-k", "start", "-D", "NO_DETACH"]
CMD /bin/bash /usr/local/bin/runme.sh
