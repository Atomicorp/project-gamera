#!/bin/sh
# Name: Master PG synchronization module
# Version: 0.1
# Description: Collect configs from plesk nodes, and generate PG configs
#
# TODO
# 1) Encrypt data with GPG


# List of clients
SERVERS=/usr/share/project-gamera/pg-clients

# Internal variables
WGET="/usr/bin/wget -q "
DATE=`date +%Y%m%d-%M:%H`
RCPTHOSTS=/var/qmail/control/rcpthosts
SMTPROUTES=/var/qmail/control/smtproutes
PGHOME=/usr/share/project-gamera/
DATADIR=$PGHOME/data/
TMPRCPTFILE=`/bin/mktemp -p $DATADIR/  rcpthosts.XXXXXXX`
TMPSMTPFILE=`/bin/mktemp -p $DATADIR/ smtproutes.XXXXXXX`


for i in `cat $SERVERS | egrep -v \#` ; do
  $WGET http://$i/$i-smtpdata.tar.gz.gpg -O $DATADIR/$i-smtpdata.tar.gz.gpg || FAILED=1
  if [ "$FAILED" != "1" ]; then
    # decrypt  data
    gpg --homedir $PGHOME/ --keyring pg.pub --secret-keyring pg.sec \
      -d $DATADIR/$i-smtpdata.tar.gz.gpg > $DATADIR/$i-smtpdata.tar.gz 2>/dev/null
    rm -f $DATADIR/$i-smtpdata.tar.gz.gpg
    pushd $DATADIR >/dev/null
      tar zxf $i-smtpdata.tar.gz >/dev/null 2>&1
      cat $i/rcpthosts  >> $TMPRCPTFILE
      cat $i/smtproutes >> $TMPSMTPFILE
    popd >/dev/null
    
  fi
done

# copy in original 
cat $RCPTHOSTS $TMPRCPTFILE | sort -u > $DATADIR/rcpthosts.new
cat $SMTPROUTES $TMPSMTPFILE | sort -u > $DATADIR/smtproutes.new

# Difference check
if ! diff -q $RCPTHOSTS $DATADIR/rcpthosts.new >/dev/null ; then
  echo RCPTHOSTS 
  cp $RCPTHOSTS $PGHOME/archive/$DATE-rcpthosts
  cp $DATADIR/rcpthosts.new $RCPTHOSTS
fi

if ! diff -q $SMTPROUTES $DATADIR/smtproutes.new >/dev/null ; then
  echo SMTPROUTES 
  cp $SMTPROUTES $PGHOME/archive/$DATE-smtproutes
  cp $DATADIR/smtproutes.new $SMTPROUTES
fi


# Cleanup
rm -rf $TMPRCPTFILE
rm -rf $TMPSMTPFILE

