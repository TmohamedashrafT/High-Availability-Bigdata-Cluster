#!/bin/bash


FLAG_FILE="/home/hadoop/.hive_setup_done"

if [[ "$HOSTNAME" == "metastore" ]]; then
  if [[ ! -f "$FLAG_FILE" ]]; then
    echo "Starting Hive Metastore..."
    schematool -dbType postgres -initSchema
    touch "$FLAG_FILE"
  else
    echo "Hive Metastore already initialized."
  fi
  hive --service metastore
else  
  until hdfs dfs -ls / >/dev/null 2>&1; do
    echo "[TEZ] Waiting for HDFS..."
    sleep 3
  done
  if ! hdfs dfs -test -f /apps/tez/tez.tar.gz; then
    echo "[TEZ] Uploading Tez tarball to HDFS..."
    hdfs dfs -mkdir -p /apps/tez
    hdfs dfs -put /opt/cluster/tez/share/tez.tar.gz /apps/tez/
  else
    echo "[TEZ] Tez tarball already uploaded."
  fi
  echo "Starting HiveServer2..."
  hive --service hiveserver2
fi



tail -f /dev/null

