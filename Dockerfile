# === Stage 1: Java Base Image ===
FROM ubuntu:24.04 AS java-base

ARG JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ARG WORKDIR=/opt/cluster

RUN apt update && \
    apt install -y \
        curl \
        wget \
        sudo \
        openjdk-8-jdk \
        tar \
        netcat-openbsd 

ENV JAVA_HOME=$JAVA_HOME
ENV PATH=$PATH:$JAVA_HOME/bin
WORKDIR $WORKDIR

COPY entrypoints/arbitrary_entrypoint.sh ./entrypoint.sh
RUN chmod +x ./entrypoint.sh
ENTRYPOINT ["./entrypoint.sh"]


# === Stage 2: Hadoop Base Image ===
FROM java-base AS hadoop-base
ARG HADOOP_VERSION=3.3.6

WORKDIR $WORKDIR

# Download and extract Hadoop using ADD
RUN wget https://downloads.apache.org/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz $WORKDIR/ && \
    tar -xzf hadoop-${HADOOP_VERSION}.tar.gz && \
    mv hadoop-${HADOOP_VERSION} hadoop && \
    rm hadoop-${HADOOP_VERSION}.tar.gz

# Copy Hadoop configuration files
COPY configs/hadoop/* $WORKDIR/hadoop/etc/hadoop/
COPY entrypoints/hadoop_entrypoint.sh ./entrypoint.sh
RUN chmod +x ./entrypoint.sh

# Set Hadoop environment variables
ENV HADOOP_HOME=$WORKDIR/hadoop
ENV HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
ENV HADOOP_LOG_DIR=$HADOOP_HOME/logs
ENV HADOOP_USER_NAME=root
ENV PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin


# === Stage 3: ZooKeeper Base Image ===
FROM java-base AS zookeeper
ARG ZK_VERSION=3.8.4

WORKDIR $WORKDIR

# Download and extract ZooKeeper using ADD
RUN wget https://downloads.apache.org/zookeeper/zookeeper-${ZK_VERSION}/apache-zookeeper-${ZK_VERSION}-bin.tar.gz $WORKDIR/ && \
    tar -xzf apache-zookeeper-${ZK_VERSION}-bin.tar.gz && \
    mv apache-zookeeper-${ZK_VERSION}-bin zookeeper && \
    rm apache-zookeeper-${ZK_VERSION}-bin.tar.gz

# Copy ZooKeeper configuration
COPY configs/zookeeper/zoo.cfg $WORKDIR/zookeeper/conf/zoo.cfg
COPY entrypoints/zk_entrypoint.sh ./entrypoint.sh

# Set ZooKeeper environment variables
ENV ZOOKEEPER_HOME=$WORKDIR/zookeeper
ENV ZOO_LOG_DIR=$ZOOKEEPER_HOME/logs
ENV PATH=$PATH:$ZOOKEEPER_HOME/bin


# === Stage 4: Add HBase ===
FROM hadoop-base AS hbase
ARG HBASE_VERSION=2.4.9

ENV HBASE_HOME=$WORKDIR/hbase
ENV PATH=$PATH:$HBASE_HOME/bin

WORKDIR $WORKDIR

RUN wget https://archive.apache.org/dist/hbase/${HBASE_VERSION}/hbase-${HBASE_VERSION}-bin.tar.gz $WORKDIR/ && \
    tar -xzf hbase-${HBASE_VERSION}-bin.tar.gz && \
    mv hbase-${HBASE_VERSION} $HBASE_HOME && \
    rm hbase-${HBASE_VERSION}-bin.tar.gz

# Copy HBase configuration and entrypoint
COPY configs/hbase/hbase-site.xml $HBASE_HOME/conf/
COPY entrypoints/hbase_entrypoint.sh ./entrypoint.sh
RUN chmod +x ./entrypoint.sh

# === Stage 5: Add Hive ===
FROM hadoop-base AS hive
ARG HIVE_VERSION=4.0.1
ARG TEZ_VERSION=0.10.4

ENV HIVE_HOME=$WORKDIR/hive
ENV TEZ_HOME=$WORKDIR/tez
ENV HIVE_CONF_DIR=$HIVE_HOME/conf
ENV TEZ_CONF_DIR=$TEZ_HOME/conf
ENV HIVE_AUX_JARS_PATH=$TEZ_HOME
ENV PATH=$PATH:$HIVE_HOME/bin:$TEZ_HOME/bin

WORKDIR $WORKDIR

# Download and extract Spark, Tez, and Hive using ADD
RUN wget https://downloads.apache.org/tez/${TEZ_VERSION}/apache-tez-${TEZ_VERSION}-bin.tar.gz $WORKDIR/ && \
    wget https://dlcdn.apache.org/hive/hive-${HIVE_VERSION}/apache-hive-${HIVE_VERSION}-bin.tar.gz $WORKDIR/ && \
    tar -xzf apache-tez-${TEZ_VERSION}-bin.tar.gz && \
    tar -xzf apache-hive-${HIVE_VERSION}-bin.tar.gz && \
    mv apache-tez-${TEZ_VERSION}-bin $TEZ_HOME && \
    mv apache-hive-${HIVE_VERSION}-bin $HIVE_HOME && \
    wget -O $HIVE_HOME/lib/postgresql-42.3.1.jar https://jdbc.postgresql.org/download/postgresql-42.3.1.jar && \
    rm *.tar.gz 

# Copy Hive and Tez configuration and entrypoint
COPY configs/hive/* $HIVE_HOME/conf/
COPY configs/tez/* $TEZ_HOME/conf/
COPY entrypoints/hive_entrypoint.sh ./entrypoint.sh

# === Stage 6: Add Spark ===
FROM hadoop-base AS hadoop-with-spark

ARG SPARK_VERSION=3.5.1
ENV SPARK_HOME=$WORKDIR/spark
ENV SPARK_LOCAL_HOSTNAME=localhost
ENV PATH=$PATH:$SPARK_HOME/bin
WORKDIR $WORKDIR

RUN wget https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop3.tgz $WORKDIR/ && \
    tar -xzf spark-${SPARK_VERSION}-bin-hadoop3.tgz && \
    mv spark-${SPARK_VERSION}-bin-hadoop3 $SPARK_HOME && \
    rm spark-${SPARK_VERSION}-bin-hadoop3.tgz

COPY configs/spark/* $SPARK_HOME/conf/
COPY entrypoints/spark_entrypoint.sh ./entrypoint.sh


