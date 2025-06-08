#!/bin/bash

# Configure ZooKeeper node ID and start server
configure_zookeeper() {
    echo "${HOSTNAME: -1}" > zookeeper/myid
    zkServer.sh start
}

# Keep container alive
tail_forever() {
    tail -f /dev/null
}

# === MAIN ===
configure_zookeeper
tail_forever
