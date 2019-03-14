#!/bin/sh
  
gzip -S ".`date +%s`.gz" /var/log/passivedns/passivedns.log
echo > /var/log/passivedns/passivedns.log
/usr/bin/docker restart pdns
