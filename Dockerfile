FROM ubuntu:18.04

ENV DEBIAN_FRONTEND="noninteractive" \
    PYTHONIOENCODING="utf-8" \
    LAMDEN_RUN_PARAMS="" \
    MONGODB_RUN_PARAMS="--bind_ip 127.0.0.1" \
    CRON_DAEMON_RUN_PARAMS="-f" \
    HAVEGED_RUN_PARAMS="--Foreground"

ARG APT_FLAGS_COMMON="-qq -y --no-install-recommends" \
    LAMDEN_REPO_BRANCH="master" \
    MONGODB_REPO_KEY="https://www.mongodb.org/static/pgp/server-5.0.asc" \
    MONGODB_REPO="deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/5.0 multiverse"

RUN apt-get update && apt-get install ${APT_FLAGS_COMMON} \
    wget \
    gnupg \
    ca-certificates \
    && wget -qO - ${MONGODB_REPO_KEY} | APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1 apt-key add - \
    && echo ${MONGODB_REPO} > /etc/apt/sources.list.d/mongodb-org-5.0.list \
    && apt-get update && apt-get install ${APT_FLAGS_COMMON} \
    mongodb-org \
    python3 \
    python3-pip \
    python3-dev \
    build-essential \
    git-core \
    haveged \
    libzmq3-dev \
    supervisor \
    cron \
    && pip3 install setuptools wheel \
    && pip3 install uvloop==0.14.0 sanic==20.12 \
    && mkdir /tmp/lamden \
    && git clone --depth 1 --branch ${LAMDEN_REPO_BRANCH} https://github.com/Lamden/lamden /tmp/lamden \
    && cd /tmp/lamden \
    && python3 /tmp/lamden/setup.py install \
    && cd / \
    && rm -rf /tmp/lamden \
    && apt-get -y purge \
    python3-dev \
    build-essential \
    git-core \
    && apt-get ${APT_FLAGS_COMMON} autoremove \
    && apt-get ${APT_FLAGS_COMMON} clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /root/.cache \
    && mkdir /entrypoint.d

COPY /assets /
WORKDIR /data/db
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
