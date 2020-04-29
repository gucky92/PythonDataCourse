# run mysql
## Pull the mysql:5.6 image
FROM datajoint/mysql:5.7

ENV MYSQL_ROOT_PASSWORD simple
ENV MYSQL_DATABASE mymysql
EXPOSE 3306
RUN mysqld

FROM continuumio/anaconda3
# install the notebook package
RUN pip install --no-cache --upgrade pip && \
    pip install --no-cache notebook && \
    conda install seaborn && \
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
