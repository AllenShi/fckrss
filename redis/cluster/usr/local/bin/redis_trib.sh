#!/bin/bash

MASTER_NODES=(172.16.151.244:6379 172.16.152.226:6380 172.16.154.214:6381)
SLAVE_NODES=(172.16.152.226:6379 172.16.154.214:6380 172.16.151.244:6381)
 
/opt/redis/redis-stable/src/redis-trib.rb create ${MASTER_NODES[*]}

IFS=':' read MASTER MPORT <<< "${MASTER_NODES[0]}"
count=0
while [ "x${MASTER_NODES[count]}" != "x" ]; do
  master_id=$(redis-cli -c -h ${MASTER} -p ${MPORT} cluster nodes | grep "${MASTER_NODES[count]}" | awk '{print $1}')
  echo "master id is ${master_id}"
  /opt/redis/redis-stable/src/redis-trib.rb add-node --slave --master-id ${master_id} ${SLAVE_NODES[count]} ${MASTER_NODES[count]}
  let count=count+1
done
