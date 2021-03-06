FROM rocker/geospatial:3.6.3

ARG HADOOP_MAJOR_VERSION="3.2"
ARG HADOOP_SHA256="2d62709c3d7144fcaafc60e18d0fa03d7d477cc813e45526f3646030cd87dbf010aeccf3f4ce795b57b08d2884b3a55f91fe9d74ac144992d2dfe444a4bbf34ee"
ARG HADOOP_URL="https://downloads.apache.org/hadoop/common/hadoop-3.2.1/"
ARG HADOOP_VERSION=3.2.1
ARG HADOOP_AWS_URL="https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws"
ARG SPARK_URL="https://downloads.apache.org/spark/spark-2.4.6/"
ARG SPARK_VERSION=2.4.6

ENV HADOOP_HOME="/opt/hadoop"
ENV SPARK_HOME="/opt/spark"

RUN mkdir -p $HADOOP_HOME $SPARK_HOME

RUN cd /tmp \
    && wget ${HADOOP_URL}hadoop-${HADOOP_VERSION}.tar.gz \
    && tar xzf hadoop-${HADOOP_VERSION}.tar.gz -C $HADOOP_HOME --owner root --group root --no-same-owner --strip-components=1 \
    && wget ${HADOOP_AWS_URL}/${HADOOP_VERSION}/hadoop-aws-${HADOOP_VERSION}.jar \
    && mkdir -p $HADOOP_HOME/share/lib/common/lib \
    && mv hadoop-aws-${HADOOP_VERSION}.jar $HADOOP_HOME/share/lib/common/lib \
    && wget ${SPARK_URL}spark-${SPARK_VERSION}-bin-without-hadoop.tgz \
    && tar xzf spark-${SPARK_VERSION}-bin-without-hadoop.tgz -C $SPARK_HOME --owner root --group root --no-same-owner --strip-components=1 \
    && rm -rf /tmp/*

ENV SPARK_OPTS --driver-java-options=-Xms1024M --driver-java-options=-Xmx4096M --driver-java-options=-Dlog4j.logLevel=info
ENV JAVA_HOME "/usr/lib/jvm/adoptopenjdk-8-hotspot-amd64"
ENV HADOOP_OPTIONAL_TOOLS "hadoop-aws"
ENV PATH="${JAVA_HOME}/bin:${SPARK_HOME}/bin:${HADOOP_HOME}/bin:${PATH}"

ENV \

    # Change the locale
    LANG=fr_FR.UTF-8 


RUN \
    # Add Shiny support
    export ADD=shiny \
    && bash /etc/cont-init.d/add \
    
    # Install system librairies
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends apt-utils software-properties-common \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        openssh-client \
        libpng++-dev \
        libudunits2-dev \
        libgdal-dev \
        curl \
        gnupg2 \
        unixodbc \
        unixodbc-dev \
	odbc-postgresql \
	libsqliteodbc \
	alien \
        libsodium-dev \
        libsecret-1-dev \
        libarchive-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && wget -qO - https://adoptopenjdk.jfrog.io/adoptopenjdk/api/gpg/key/public | apt-key add - \
    && add-apt-repository --yes https://adoptopenjdk.jfrog.io/adoptopenjdk/deb/ \
    && sudo apt update -y \
    && apt install -y adoptopenjdk-8-hotspot \

    # Handle localization
    && cp /usr/share/zoneinfo/Europe/Paris /etc/localtime \
    && sed -i -e 's/# fr_FR.UTF-8 UTF-8/fr_FR.UTF-8 UTF-8/' /etc/locale.gen \
    && dpkg-reconfigure --frontend=noninteractive locales \
    && update-locale LANG=fr_FR.UTF-8


RUN \
    
    R -e "update.packages(ask = 'no')" \
    && install2.r --error \
        RPostgreSQL \
        RSQLite \
        odbc \
        keyring \
        aws.s3 \
	paws
    
    
VOLUME ["/home"]
