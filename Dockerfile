FROM ubuntu:20.04

ENV DEBIAN_FRONTEND noninteractive
ARG APT_FLAGS_COMMON="-qq -y --no-install-recommends" \
    MONGODB_REPO_KEY="https://www.mongodb.org/static/pgp/server-5.0.asc" \
    MONGODB_REPO="deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/5.0 multiverse"

ENV USER_NAME="lamden" \
    USER_GROUP="lamden" \
    USER_HOME="/lamden" \
    USER_ID="1000" \
    GROUP_ID="1000"

RUN apt-get update && apt-get install ${APT_FLAGS_COMMON} \
    python3 \
    python3-pip \
    python3-setuptools \
    python3-dev \
    build-essential \
    wget \
    gnupg \
    haveged \
    libzmq3-dev \
    supervisor \
    cron \
    && apt-get ${APT_FLAGS_COMMON} autoremove \
    && apt-get ${APT_FLAGS_COMMON} clean \
    && rm -rf /var/lib/apt/lists/*

RUN wget -qO - ${MONGODB_REPO_KEY} | APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1 apt-key add - \
    && echo ${MONGODB_REPO} > /etc/apt/sources.list.d/mongodb-org-5.0.list \
    && apt-get update && apt-get install ${APT_FLAGS_COMMON} \
    mongodb-org \
    && apt-get ${APT_FLAGS_COMMON} autoremove \
    && apt-get ${APT_FLAGS_COMMON} clean \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install lamden

COPY /assets /
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/lamden/supervisor/supervisord.conf"]
