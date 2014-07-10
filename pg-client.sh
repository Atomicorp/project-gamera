#!/bin/sh
# Name: Project Gamera client module
# Version: 0.2
# Description: Parse PSA configs and generate PG files
#
# TODO
# 1) Encrypt data with GPG key from master

# Default website dir
DOCHOME=/var/www/vhosts/default/htdocs/

# Do we have the gpg key?
gpg --list-key Project > /dev/null 2>&1 || NOKEY=1

if [ "$NOKEY" ]; then
  echo -n "Enter path to Project Gamera servers public key: "
  read keyfile < /dev/tty
  if [ -f $keyfile ]; then
    gpg --import $keyfile
  else 
    echo "Invalid path, exiting"
    exit 1
  fi
fi


# make a temp dir
TMPDIR=`/bin/mktemp -d -t` || exit 1

# Get the local IP
IP=`/sbin/ifconfig eth0 | sed -n -e 's/^.*inet addr:\([0-9][0-9\.]*\).*$/\1/p'`
mkdir -p $TMPDIR/$IP

# Copy rcpthosts to tempdir
cp /var/qmail/control/rcpthosts $TMPDIR/$IP/

# Get rcpthosts
for i in `cat /var/qmail/control/rcpthosts`; do
  echo "$i:$IP" >> $TMPDIR/$IP/smtproutes
done

cd $TMPDIR
tar zcf $IP-smtpdata.tar.gz $IP
# Encrypt with server key 
gpg --always-trust -r Atomic -e $IP-smtpdata.tar.gz 

mv $IP-smtpdata.tar.gz.gpg $DOCHOME/

# remove temp dir
rm -rf $TMPDIR

