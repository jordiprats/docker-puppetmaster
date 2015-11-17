#!/bin/bash


touch /etc/puppet/hiera.yaml

cat <<EOF > /tmp/manifest.pp

class { 'puppet':
  basemodulepath => '/etc/local-puppet-modules',
}

class { 'puppet::master':
  certname => '${EYP_PUPPETFQDN}',
  manage_service => false,
}

EOF

puppet apply --modulepath=/usr/local/src/puppetmodules/ /tmp/manifest.pp


/usr/sbin/apache2 -k start -D NO_DETACH
