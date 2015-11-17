#!/bin/bash


touch /etc/puppet/hiera.yaml

mkdir -p $EYP_PUPPET_LOCAL_MODULES

cat <<EOF > /tmp/manifest.pp

class { 'puppet':
  basemodulepath => '${EYP_PUPPET_LOCAL_MODULES}',
}

class { 'puppet::master':
  certname => '${EYP_PUPPETFQDN}',
  manage_service => false,
}

EOF

puppet apply --modulepath=/usr/local/src/puppetmodules/ /tmp/manifest.pp


/usr/sbin/apache2 -k start -D NO_DETACH
