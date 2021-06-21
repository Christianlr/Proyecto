FROM debian:9

# Instalacion de las herramientas basicas
RUN \
  apt-get update && apt-get install -y \
  ssh \
  python3 \
  nano \
  curl \
  wget \
  vim \
  openjdk-8-jdk

###########################
###INSTALACION DE HADOOP###
###########################

# Descarga del paquete de hadoop y configuracion
RUN \
  wget http://apachemirror.wuchna.com/hadoop/common/hadoop-3.2.1/hadoop-3.2.1.tar.gz && \
  tar -xzf hadoop-3.2.1.tar.gz && \
  mv hadoop-3.2.1 /opt/hadoop && \
  mkdir -p /opt/hadoopdata/hdfs/namenode && \
  mkdir -p /opt/hadoopdata/hdfs/datanode

ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV HADOOP_HOME=/opt/hadoop
ENV HADOOP_INSTALL=$HADOOP_HOME
ENV HADOOP_MAPRED_HOME=$HADOOP_HOME
ENV HADOOP_COMMON_HOME=$HADOOP_HOME
ENV HADOOP_HDFS_HOME=$HADOOP_HOME
ENV HADOOP_YARN_HOME=$HADOOP_HOME
ENV HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/native
ENV PATH=$PATH:$HADOOP_HOME/sbin:$HADOOP_HOME/bin
ENV HADOOP_OPTS="-Djava.library.path=$HADOOP_HOME/lib/native"

RUN echo "export HDFS_DATANODE_USER=root" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
    echo "export HDFS_NAMENODE_USER=root" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
    echo "export HDFS_SECONDARYNAMENODE_USER=root" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
    echo "export YARN_RESOURCEMANAGER_USER=root" >> $HADOOP_HOME/etc/hadoop/yarn-env.sh && \
    echo "export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
    echo "export YARN_NODEMANAGER_USER=root" >> $HADOOP_HOME/etc/hadoop/yarn-env.sh

# Creacion de la clave ssh
RUN \
  ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa && \
  cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && \
  chmod 0600 ~/.ssh/authorized_keys

# Copia de archivos de configuracion
ADD configs/*xml $HADOOP_HOME/etc/hadoop/

# Copia de la configuracion de SSH y script
ADD configs/ssh_config /root/.ssh/config

ADD configs/start-all.sh start-all.sh

ADD configs/.bashrc /root/.bashrc


######################
#INSTALACION DE SPARK#
######################


#Descargamos las dependencias de spark

ADD  configs/spark-3.1.1-bin-hadoop3.2.tgz /opt
RUN mv /opt/spark-3.1.1-bin-hadoop3.2 /opt/spark
#Ahora necesitamos hacer que las plantillas que vienen dentro de spark nos sirvan para tener una confguracion basica
RUN cp /opt/spark/conf/fairscheduler.xml.template /opt/spark/conf/fairscheduler.xml && \
cp /opt/spark/conf/log4j.properties.template /opt/spark/conf/log4j.properties && \
cp /opt/spark/conf/metrics.properties.template /opt/spark/conf/metrics.properties && \
cp /opt/spark/conf/spark-defaults.conf.template /opt/spark/conf/spark-defaults.conf && \
cp /opt/spark/conf/spark-env.sh.template /opt/spark/conf/spark-env.sh && \
cp /opt/spark/conf/workers.template /opt/spark/conf/workers

#añadimos las configuraciones necesarias

RUN echo "master" > /opt/spark/conf/workers && \
        echo "SPARK_MASTER_HOST=master" >> /opt/spark/conf/spark-env.sh && \
        echo "HADOOP_CONF_DIR=/opt/hadoop/etc/hadoop" >> /opt/spark/conf/spark-env.sh && \
        echo "SPARK_LOCAL_IP=master" >> /opt/spark/conf/spark-env.sh




# exponemos los puertos
EXPOSE 9870 8088 4040 8089 8888 8080

#ejecutamos el comando que inicia todos los servicios necesarios

CMD bash start-all.sh


########################
#INSTALACION DE JUPYTER#
########################


#Descargamos lo necesario para tener anaconda3.

RUN wget https://repo.anaconda.com/archive/Anaconda3-2020.02-Linux-x86_64.sh

#Tras haber configurado correctamente Anaconda, descargamos lo necesario para jupyter

#RUN conda install jupyter

#Generamos la configuracion de Jupyter y agregamos siguiente sentencia para permitir la conexion mediando un navegador web

#RUN jupyter notebook --generate-config
