# FROM docker:latest
# EXPOSE 3306
# RUN apk add --no-cache py-pip python-dev libffi-dev openssl-dev gcc libc-dev make && \
#    pip install docker-compose
# ADD . /app
# WORKDIR /app
# RUN docker-compose up -d
# run mysql
## Pull the mysql:5.6 image
FROM ubuntu:16.04
RUN apt-get update \
    &&  apt-get -y install mysql-server \
    &&  service mysql start \
    &&  mysqladmin -u root password simple
# FROM datajoint/mysql:5.7
# ENV MYSQL_ROOT_PASSWORD simple
# FROM ubuntu:16.04
# ADD . /app
# WORKDIR /app

ENTRYPOINT service mysql start
# RUN mysqld --initialize
# RUN apt-get update && \
#    apt-get install -y mysql-server && \
#    mysql_secure_installation --defaults_file=my.cnf
# RUN
# RUN service mysqld start
# COPY ./docker-entrypoint.sh /
# ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 3306

FROM continuumio/anaconda3
# install the notebook package
RUN pip install --no-cache --upgrade pip && \
    pip install --no-cache notebook && \
    pip install seaborn && \
    python -m pip install git+https://github.com/gucky92/datajoint-python.git

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
