#!/bin/bash

/etc/init.d/ssh start

# START HADOOP
##############
$HADOOP_HOME/bin/hdfs namenode -format

tail -f /dev/null