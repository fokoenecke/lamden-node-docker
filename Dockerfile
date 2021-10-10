FROM ubuntu:18.04

ENV DEBIAN_FRONTEND="noninteractive" \
    PYTHONIOENCODING="utf-8" \
    LAMDEN_RUN_PARAMS="" \
    MONGODB_RUN_PARAMS="--bind_ip 127.0.0.1" \
    CRON_DAEMON_RUN_PARAMS="-f" \
    HAVEGED_RUN_PARAMS="--Foreground" \
    USER_NAME="lamden" \
    USER_GROUP="lamden" \
    USER_HOME="/lamden" \
    USER_ID="1000" \
    GROUP_ID="1000"

ARG APT_FLAGS_COMMON="-qq -y --no-install-recommends" \
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
    python3-setuptools \
    python3-dev \
    build-essential \
    git-core \
    haveged \
    libzmq3-dev \
    supervisor \
    cron \
    && pip3 install sanic==20.12 \
    && mkdir /tmp/lamden \
    && git clone https://github.com/Lamden/lamden /tmp/lamden \
    && cd /tmp/lamden \
    && python3 /tmp/lamden/setup.py install \
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
WORKDIR /lamden
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/lamden/supervisor/supervisord.conf"]
