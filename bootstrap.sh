#!/bin/bash

sed 's/START=.*/START=yes/' -i /etc/default/puppetmaster

/etc/init.d/puppetmaster start

sleep 1

/etc/init.d/puppetmaster stop

sed 's/START=.*/START=no/' -i /etc/default/puppetmaster

