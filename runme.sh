#!/bin/bash

if [ ! -f /etc/puppet/puppet.conf ];
then

  touch /etc/puppet/hiera.yaml

  cat <<EOF > /tmp/manifest.pp

  class { 'puppet': }

	class { 'puppet::master':
    certname => '${EYP_PUPPETFQDN}',
    manage_service => false,
	}

EOF

  puppet apply --modulepath=/usr/local/src/puppetmodules/ /tmp/manifest.pp

fi

/usr/sbin/apache2 -k start -D NO_DETACH
