#!/bin/bash

exec >/modules/logs/puppetmaster.startup.${EYP_INSTANCE_NUMBER}.log 2>&1

touch /etc/puppet/hiera.yaml

mkdir -p $EYP_PUPPET_INSTANCE_MODULES

cat <<EOF > /tmp/manifest.pp

class { 'puppet':
  basemodulepath => '${EYP_PUPPET_INSTANCE_MODULES}',
}

class { 'puppet::master':
  certname => '${EYP_PUPPETFQDN}',
  manage_service => false,
}

EOF

puppet apply --modulepath=/usr/local/src/puppetmodules/ /tmp/manifest.pp

for i in $(tar tvf /modules/puppetball.tgz  | awk '{ print $NF }' | cut -f 1,2 -d-);
do
  echo "= $i ="

  if [ ! -z "${EYP_INSTERNAL_FORGE}" ];
  then
    EYP_MODULE_REPOSITORY="--module_repository=${EYP_INSTERNAL_FORGE}"
  fi

  puppet module install $i $EYP_MODULE_REPOSITORY
fi

/usr/sbin/apache2 -k start -D NO_DETACH
