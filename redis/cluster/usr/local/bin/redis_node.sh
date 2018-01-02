#!/bin/bash

MASTER_PORT=6379
SLAVE_PORT=6381
MASTER_NAME=a
SLAVE_NAME=c

function start() {
  if [ -e /var/lock/redis ]; then
    echo "redis service is already started"
    exit
  else
    touch /var/lock/redis
    mkdir -p /var/log/redis
    echo "Starting redis master ${MASTER_NAME}"
    nohup redis-server /etc/redis/${MASTER_NAME}_master.conf 1>/var/log/redis/redis_${MASTER_NAME}_master.log 2>&1 & 
    echo "Starting redis slave ${SLAVE_NAME}"
    nohup redis-server /etc/redis/${SLAVE_NAME}_slave.conf 1>/var/log/redis/redis_${SLAVE_NAME}_slave.log 2>&1 &
  fi
}

function stop() {
  echo "Stopping redis master ${MASTER_NAME} PID=$(cat /var/run/redis_${MASTER_PORT}.pid)"
  kill $(cat /var/run/redis_${MASTER_PORT}.pid)
  echo "Stopping redis slave ${SLAVE_NAME} PID=$(cat /var/run/redis_${SLAVE_PORT}.pid)"
  kill $(cat /var/run/redis_${SLAVE_PORT}.pid)
  rm /var/run/redis*.pid
  rm /var/lock/redis
}

function status() {
  ps -ef | grep redis | grep -v grep
  echo "redis master ${MASTER_NAME} PID=$(cat /var/run/redis_${MASTER_PORT}.pid)"
  echo "redis slave ${SLAVE_NAME} PID=$(cat /var/run/redis_${SLAVE_PORT}.pid)"
}

case "$1" in
  start)
    start
    ;;
  stop)
    stop
    ;;
  status)
    status
    ;;
  reload)
    stop
    sleep 1
    start
    ;;
  *)
    echo "Usage $0 {start | stop | status | reload}"
    exit 1
    ;;
esac

exit 0
