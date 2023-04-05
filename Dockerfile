from ubuntu:20.04

arg image_ver

RUN set -ex \
    ;apt-get update -y \
    ;apt-get -y install --no-install-recommends \
    vim-tiny \
    iproute2 \
    curl \
    ca-certificates \
    lsb-release \
    gnupg2 \
    ;update-alternatives --install /usr/bin/vim vim /usr/bin/vim.tiny 1 \
    ;curl -sSO https://dl.google.com/cloudagents/add-monitoring-agent-repo.sh \
    ;bash add-monitoring-agent-repo.sh --also-install --version=${image_ver} \
    ;apt-get autoclean \
    ;apt-get clean \
    ;rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /
COPY collectd.conf /etc/stackdriver/collectd.conf

ENTRYPOINT ["/entrypoint.sh"]
