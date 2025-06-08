#!/bin/bash

# Start the JournalNode service
start_journalnode() {
    hdfs --daemon start journalnode
    sleep 5
}

# Format NameNode if running on master1
format_namenode() {
    if [[ "$(hostname)" == "master1" ]]; then
        if [ ! -d "/tmp/hadoop-root/dfs/name/current" ]; then
            echo "Formatting NameNode on master1..."
            hdfs namenode -format
            echo "Formatting ZKFC..."
            hdfs zkfc -formatZK
        else
            echo "NameNode already formatted, skipping..."
            echo "ZKFC already formatted, skipping..."
        fi
    else
        echo "This is not master1, skipping NameNode formatting."
    fi

    echo "Starting NameNode on $(hostname)..."
    hdfs --daemon start namenode
}

# Wait until NameNode on master1 is reachable
wait_for_namenode() {
    if [[ "$(hostname)" != "master1" ]]; then
        while true; do
            if curl -s "http://master1:9870/jmx" | grep -q "NameNode"; then
                echo "NameNode is active on master1. Proceeding..."
                break
            else
                echo "Waiting for NameNode on master1..."
                sleep 5
            fi
        done
    fi
}

# Bootstrap standby NameNode if needed
bootstrap_namenode() {
    if [[ "$(hostname)" != "master1" ]]; then
        if [ ! -d "/tmp/hadoop-hadoop/dfs/name/current" ]; then
            echo "Bootstrapping standby NameNode on $(hostname)..."
            hdfs namenode -bootstrapStandby
        else
            echo "Standby NameNode already bootstrapped, skipping..."
        fi
    fi

    echo "Starting NameNode on $(hostname)..."
    hdfs --daemon start namenode
}

# Start ResourceManager and ZKFC
start_services() {
    echo "Starting ZKFC..."
    hdfs --daemon start zkfc

    echo "Starting ResourceManager..."
    yarn --daemon start resourcemanager
}

# Start DataNode and NodeManager
start_worker_service() {
    hdfs --daemon start datanode
    yarn --daemon start nodemanager
}

# Keep the container alive
tail_forever() {
    tail -f /dev/null
}

# === MAIN ENTRYPOINT ===
if [[ "$HOSTNAME" == *master* ]]; then
    start_journalnode
    format_namenode
    wait_for_namenode
    bootstrap_namenode
    start_services
else
    start_worker_service
fi

tail_forever
