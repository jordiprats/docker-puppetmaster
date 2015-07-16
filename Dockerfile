FROM ubuntu:14.04
MAINTAINER Jordi Prats

RUN wget http://apt.puppetlabs.com/puppetlabs-release-wheezy.deb

RUN dpkg -i puppetlabs-release-wheezy.deb

RUN apt-get update

RUN apt-get install -y puppet puppet-common puppet-el puppet-testsuite puppetmaster puppetmaster-common vim-puppet puppetmaster-passenger

RUN sed -i "s/START=yes/START=no/g" /etc/default/puppetmaster


