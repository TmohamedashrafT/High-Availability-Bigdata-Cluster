#!/bin/bash

export SPARK_DRIVER_IP=$(hostname -I | awk '{print $1}')
echo "spark.driver.host $SPARK_DRIVER_IP" >> $SPARK_HOME/conf/spark-defaults.conf
hdfs dfs -mkdir /spark-logs
hdfs dfs -mkdir /spark-jars
hdfs dfs -put $SPARK_HOME/jars/* /spark-jars/
/opt/cluster/spark/sbin/start-history-server.sh

tail -f /dev/null
