FROM ubuntu:16.04
MAINTAINER IsaacHwang <dkhwang@bitnine.net>

RUN apt-get update -y \
    && apt-get install -y python-software-properties software-properties-common \
    && add-apt-repository -y ppa:openjdk-r/ppa \
    && apt-get update -y \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y net-tools apt-transport-https ca-certificates software-properties-common libkeyutils-dev libnspr4 vim apt-utils wget curl sudo python2.7 python-pip openjdk-7-jdk locales libpq-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/* \
    && useradd -m -c "AgensGraph User" -U agraph \
    && echo 'agraph ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers \
    && pip install psycopg2 \
    && pip install konlpy \
    && ln -s /usr/lib/x86_64-linux-gnu/libpython2.7.so.1.0 /usr/lib/x86_64-linux-gnu/libpython2.6.so.1.0 \
    && ln -s /usr/lib/python2.7/plat-*/_sysconfigdata_nd.py /usr/lib/python2.7/ 

COPY AgensGraph_v1.3.1_linux.tar.gz /home/agraph/

ENV AG_CONF_TEMPLATE_DIR=/home/agraph/AgensGraph/share/postgresql \
    AGDATA=/home/agraph/data/data \
    PATH=/home/agraph/AgensGraph/bin:$PATH \
    LD_LIBRARY_PATH=/home/agraph/AgensGraph/lib:$LD_LIBRARY_PATH \
    PYTHONHOME=/usr/lib/python2.7 \
    PYTHONPATH=/usr/lib/python2.7:/usr/local/lib/python2.7:/usr/local/lib/python2.7/site-packages:/usr/local/lib/python2.7/dist-packages:/usr/lib/python2.7/lib-dynload \
    LANGUAGE=ko_KR.UTF-8 \
    LANG=ko_KR.UTF-8

RUN cd /home/agraph && tar -zxvf AgensGraph_v1.3.1_linux.tar.gz && \ 
    rm -rf AgensGraph_v1.3.1_linux.tar.gz && \
    locale-gen ko_KR ko_KR.UTF-8 && \
    update-locale LANG=ko_KR.UTF-8

COPY conf/pg_hba.conf /home/agraph/AgensGraph/share/postgresql/pg_hba.conf.sample
COPY conf/postgresql.conf /home/agraph/AgensGraph/share/postgresql/postgresql.conf.sample

ADD script/* /home/agraph/script/
ADD extensions/pg_cron-master /home/agraph/

RUN chown -R 'agraph:agraph' /home/agraph && \
    chmod +x /home/agraph/script/entrypoint.sh

USER agraph
WORKDIR /home/agraph    

EXPOSE 5432
ENTRYPOINT ["/home/agraph/script/entrypoint.sh"]

