#!/bin/sh

RETVAL=0
QMHANDLE="/usr/bin/qmhandle.pl"
CONFIRMED=0
FAILED=0
SLEEP=3

# Stop daemon
while [ $CONFIRMED -lt 1  ]; do
  if [ $FAILED -gt 10 ]; then
    echo "Error: qmail could not be stopped."
    exit 1
  fi


  /usr/bin/svc-stop qmail
  RETVAL=$?

  if [ $RETVAL -ne 0 ]; then
    FAILED=$(( $FAILED +1))
    echo "Sleeping for $SLEEP..."
    sleep $SLEEP
    SLEEP=$(( $SLEEP + 3))
    if [ $SLEEP -gt 30 ]; then
      /usr/bin/killall qmail-remote
    fi
  else
    CONFIRMED=1
  fi
done

# Clear event
$QMHANDLE -Sfailure

# Start daemn
/usr/bin/svc-start qmail
if [ $RETVAL -ne 0 ]; then
  echo "Error: qmail could not be started."
  exit 1
fi


