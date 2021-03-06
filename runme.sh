#!/bin/bash

mkdir -p ${EYP_PUPPET_STARTUP_LOGDIR}
exec >${EYP_PUPPET_STARTUP_LOGDIR}/puppetmaster.startup.${EYP_INSTANCE_NUMBER}.log 2>&1

apt-get update

puppet module install puppetlabs-stdlib --version 4.17.1 --modulepath=/usr/local/src/puppetmodules/
puppet module install puppetlabs-concat --version 2.2.1 --modulepath=/usr/local/src/puppetmodules/

touch /etc/puppet/hiera.yaml

mkdir -p $EYP_PUPPET_INSTANCE_MODULES

cat <<EOF > /tmp/manifest.pp

class { 'puppet':
  basemodulepath => '${EYP_PUPPET_INSTANCE_MODULES}',
}

class { 'puppet::master':
  certname => '${EYP_PUPPETFQDN}',
  manage_service => false,
  logstash_host => '${EYP_ELK_HOST}',
}

EOF

puppet apply --modulepath=/usr/local/src/puppetmodules/ /tmp/manifest.pp

for i in $(tar tvf /modules/puppetball.tgz  | awk '{ print $NF }' | cut -f 1,2 -d- | sort);
do
  echo "= $i ="

  if [ ! -z "${EYP_INTERNAL_FORGE}" ];
  then
    EYP_MODULE_REPOSITORY="--module_repository=${EYP_INTERNAL_FORGE}"
  fi

  puppet module install $i $EYP_MODULE_REPOSITORY
done

/usr/sbin/apache2 -k start -D NO_DETACH
