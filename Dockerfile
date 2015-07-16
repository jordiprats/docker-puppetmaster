FROM centos:centos6
MAINTAINER Jordi Prats

RUN yum clean all

RUN rpm -Uvh http://yum.puppetlabs.com/puppetlabs-release-el-6.noarch.rpm

RUN rpm -Uvh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm

RUN yum update -y

RUN yum install facter puppet-server hiera-puppet puppet httpd mod_ssl rubygem-rack mod_passenger -y




