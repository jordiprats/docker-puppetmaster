#!/bin/bash


touch /etc/puppet/hiera.yaml

cat <<EOF > /tmp/manifest.pp

class { 'puppet': }

class { 'puppet::master':
  certname => '${EYP_PUPPETFQDN}',
  manage_service => false,
  modulepath => '/etc/local-puppet-modules',
  basemodulepath => '/etc/local-puppet-modules',
}

EOF

puppet apply --modulepath=/usr/local/src/puppetmodules/ /tmp/manifest.pp


/usr/sbin/apache2 -k start -D NO_DETACH
