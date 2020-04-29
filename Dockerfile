# FROM docker:latest
# EXPOSE 3306
# RUN apk add --no-cache py-pip python-dev libffi-dev openssl-dev gcc libc-dev make && \
#    pip install docker-compose
# ADD . /app
# WORKDIR /app
# RUN docker-compose up -d
# run mysql
## Pull the mysql:5.6 image
#FROM ubuntu:16.04
#RUN apt-get update \
#    &&  apt-get -y install mysql-server \
#    &&  service mysql start \
#    &&  mysqladmin -u root password simple
# FROM datajoint/mysql:5.7
# ENV MYSQL_ROOT_PASSWORD simple
# FROM ubuntu:16.04
# ADD . /app
# WORKDIR /app
# ENTRYPOINT service mysql start
# RUN mysqld --initialize
# RUN apt-get update && \
#    apt-get install -y mysql-server && \
#    mysql_secure_installation --defaults_file=my.cnf
# RUN
# RUN service mysqld start
# COPY ./docker-entrypoint.sh /
# ENTRYPOINT ["/docker-entrypoint.sh"]
# EXPOSE 3306
FROM mysql:5.7

RUN \
    apt-get update && \
    apt-get -y install openssl && \
    mkdir /mysql_keys && \
    chown mysql:mysql /mysql_keys

USER mysql
RUN \
    cd /mysql_keys;\
    # Create CA certificate
    openssl genrsa 2048 > ca-key.pem;\
    openssl req -subj '/CN=CA/O=MySQL/C=US' -new -x509 -nodes -days 3600 \
            -key ca-key.pem -out ca.pem;\
    # Create server certificate, remove passphrase, and sign it
    # server-cert.pem = public key, server-key.pem = private key
    openssl req -subj '/CN=SV/O=MySQL/C=US' -newkey rsa:2048 -days 3600 \
            -nodes -keyout server-key.pem -out server-req.pem;\
    openssl rsa -in server-key.pem -out server-key.pem;\
    openssl x509 -req -in server-req.pem -days 3600 \
            -CA ca.pem -CAkey ca-key.pem -set_serial 01 -out server-cert.pem;\
    # Create client certificate, remove passphrase, and sign it
    # client-cert.pem = public key, client-key.pem = private key
    openssl req -subj '/CN=CL/O=MySQL/C=US' -newkey rsa:2048 -days 3600 \
            -nodes -keyout client-key.pem -out client-req.pem;\
    openssl rsa -in client-key.pem -out client-key.pem;\
    openssl x509 -req -in client-req.pem -days 3600 \
            -CA ca.pem -CAkey ca-key.pem -set_serial 01 -out client-cert.pem
USER root

ADD my.cnf /etc/mysql/my.cnf

HEALTHCHECK       \
    --timeout=5s \
    --retries=60  \
    --interval=1s \
    CMD           \
        mysql --protocol TCP -u"root" -p"simple" -e "show databases;"

FROM continuumio/anaconda3
# install the notebook package
RUN pip install --no-cache --upgrade pip && \
    pip install --no-cache notebook && \
    pip install seaborn && \
    conda install -c conda-forge docker-compose && \
    python -m pip install git+https://github.com/gucky92/datajoint-python.git

EXPOSE 3306
# create user with a home directory
ARG NB_USER
ARG NB_UID
ENV USER ${NB_USER}
ENV HOME /home/${NB_USER}

RUN adduser --disabled-password \
    --gecos "Default user" \
    --uid ${NB_UID} \
    ${NB_USER}
WORKDIR ${HOME}
USER ${USER}
