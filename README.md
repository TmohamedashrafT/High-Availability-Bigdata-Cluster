# 🚀 High Availability Big Data Cluster
## Project Overview
A fully distributed, high-availability big data cluster built with Docker, featuring:

- 🦁 Hadoop HDFS (3 NameNodes for HA)
- 🎯 YARN (3 ResourceManagers for HA)
- 🐘 ZooKeeper (3-node ensemble)
- 🐋 HBase (distributed NoSQL)
- 🐝 Hive (with PostgreSQL metastore)
- ⚡ Spark (fast processing)
- 🌀 Tez (optimized execution)

## 📌 Architecture Overview

### 🗂️ Core Components

| **Component Type**     | **Node(s)**                 | **Services Running**                          | **Data Volumes**                   |
|------------------------|-----------------------------|-----------------------------------------------|----------------------------------|
| **ZooKeeper Ensemble** | zk1, zk2, zk3              | ZooKeeper                                     | -                                |
| **HDFS & YARN Masters**| master1, master2, master3  | NameNode, ResourceManager                      | -                                |
| **HBase Masters**      | hmaster1, hmaster2         | HMaster                                       | -                                |
| **Hadoop Worker**      | worker1                    | DataNode, NodeManager                          | `worker1_data`                   |
| **HBase RegionServers**| rsworker1, rsworker2       | RegionServer, DataNode, NodeManager            | `rs_worker1_data`, `rs_worker2_data` |
| **Metadata Services**  | metastore, postgres-hive   | Hive Metastore, PostgreSQL                     | `db_data`                       |
| **Query Services**     | hiveserver                 | HiveServer2                                   | -                                |
| **Compute Services**   | sparkclient                | Spark Client                                  | -                                |

# Core Services

## Hadoop HDFS (High Availability)
- 3 NameNodes (active/standby)
- JournalNodes for shared edits
- Automatic failover via ZooKeeper
- Replication factor: 2

## YARN (High Availability)
- 3 ResourceManagers
- Automatic failover
- NodeManager on worker nodes

## ZooKeeper Ensemble
- 3 nodes for quorum
- Used for HDFS and YARN HA coordination

# Data Processing

## HBase
- Distributed NoSQL database
- Integrated with HDFS
- 2 HMaster nodes for HA
- 2 RegionServers

## Hive
- Data warehouse system
- PostgreSQL metastore
- Tez execution engine
- HiveServer2 for JDBC access

## Spark
- Distributed processing engine
- Runs on YARN
- History server for monitoring

## Tez
- DAG-based execution engine
- Used by Hive for improved performance

### Accessing Services

| **Service**       | **Host Ports**       | **Container Ports**   | **Purpose**                         |
|-------------------|----------------------|----------------------|-----------------------------------|
| **master1/2/3**   | 9871-9873, 8071-8073 | 9870, 8088           | HDFS NameNode UI & YARN RM UI     |
| **PostgreSQL**    | 5434                 | 5432                 | Hive Metastore Database           |
| **Hive**          | 9083, 10000, 10002   | 9083, 10000, 10002   | Metastore, HiveServer2 (JDBC/Web)|
| **Spark Client**  | 4040, 18080          | 4040, 18080          | Spark UI & History Server         |
| **HBase Masters** | 16001-16002, 16011-16012 | 16000, 16010      | HBase Master RPC & Web UI         |

# Getting Started

## Prerequisites
- Docker installed
- Minimum 8GB RAM recommended
- Linux or macOS (Windows users require WSL2)

## Deployment
1. Clone the repository:
   ```bash
   git clone https://github.com/TmohamedashrafT/High-Availability-Bigdata-Cluster.git
2. Navigate to the project directory:
   ```bash
   cd High-Availability-Bigdata-Cluster
3. Build and start the cluster:
   ```bash
   docker-compose up -d --build
