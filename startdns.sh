#!/bin/bash
MAC="$(curl --max-time 30 -s http://169.254.169.254/latest/meta-data/network/interfaces/macs/)"
VPCCIDR="$(curl --max-time 30 -s http://169.254.169.254/latest/meta-data/network/interfaces/macs/"$MAC"/vpc-ipv4-cidr-block)"
VPCNET="${VPCCIDR%%/*}"
VPCBASE="$(echo "$VPCNET" | cut -d"." -f1-3)"
[[ -z "$VPCBASE" ]] && VPCBASE=127.0.0
VPCDNS="$VPCBASE"'.2'
sed s/DNSIP/"$VPCDNS"/ /etc/bind/named.conf.options.template > /etc/bind/named.conf.options

# Start the first process : Bind Named
/usr/sbin/named -u bind
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start bind: $status"
  exit $status
fi

# Start the second process : Prometheus bind exporter
/usr/bin/prometheus-bind-exporter \
  --bind.pid-file=/var/run/named/named.pid \
  --bind.timeout=20s \
  --web.listen-address=0.0.0.0:9153 \
  --web.telemetry-path=/metrics \
  --bind.stats-url=http://localhost:8053/ \
  --bind.stats-groups=server,view,tasks &
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start prometheus-bind-exporter: $status"
  exit $status
fi

# Naive check runs checks once a minute to see if either of the processes exited.
# This illustrates part of the heavy lifting you need to do if you want to run
# more than one service in a container. The container exits with an error
# if it detects that either of the processes has exited.
# Otherwise it loops forever, waking up every 60 seconds

while sleep 60; do
  ps aux |grep named |grep -q -v grep
  PROCESS_1_STATUS=$?
  ps aux |grep prometheus-bind-exporter |grep -q -v grep
  PROCESS_2_STATUS=$?
  # If the greps above find anything, they exit with 0 status
  # If they are not both 0, then something is wrong
  if [ $PROCESS_1_STATUS -ne 0 -o $PROCESS_2_STATUS -ne 0 ]; then
    echo "One of the processes has already exited."
    exit 1
  fi
done
