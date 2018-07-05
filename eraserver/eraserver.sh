#!/bin/sh

if [ ! -z "$ProductInstanceID" ] && [ -f /etc/opt/eset/RemoteAdministrator/Server/config.cfg ]
then
  sed -i "s/^ProductInstanceID=.*/ProductInstanceID=$ProductInstanceID/g" /etc/opt/eset/RemoteAdministrator/Server/config.cfg
fi

/etc/init.d/eraserver start
