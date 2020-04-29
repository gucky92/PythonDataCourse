
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
