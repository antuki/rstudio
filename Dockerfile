FROM rocker/geospatial

ENV \

    # Change the locale
    LANG=fr_FR.UTF-8 

RUN \
    # Add Shiny support
    export ADD=shiny \
    && bash /etc/cont-init.d/add \
    
    # Install system librairies
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends apt-utils \
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
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \

    # Handle localization
    && cp /usr/share/zoneinfo/Europe/Paris /etc/localtime \
    && sed -i -e 's/# fr_FR.UTF-8 UTF-8/fr_FR.UTF-8 UTF-8/' /etc/locale.gen \
    && dpkg-reconfigure --frontend=noninteractive locales \
    && update-locale LANG=fr_FR.UTF-8 \

RUN \
    
    R -e " \
        update.packages(ask ='no'); \
        install.packages(c('RPostgreSQL', 'RSQLite', 'ROracle', 'odbc', 'keyring')); \
        remotes::install_github('cloudyr/aws.s3@ee5b4a37027b21673f3d6af3a934e69ade5476d0') ; \
    " \
    
    
VOLUME ["/home"]