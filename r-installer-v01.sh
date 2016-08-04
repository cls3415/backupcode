#!/usr/bin/env bash


# Add in necessary environment values.
echo "HADOOP_HOME=/usr/hdp/current/hadoop-client" | sudo tee -a /etc/environment
echo "HADOOP_CMD=/usr/bin/hadoop" | sudo tee -a /etc/environment
echo "HADOOP_STREAMING=$hadoopStreamingJar" | sudo tee -a /etc/environment
echo "LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib/jvm/java-7-openjdk-amd64/jre/lib/amd64/server" | sudo tee -a /etc/environment
