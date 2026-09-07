FROM golang:1.25-bookworm AS amneziawg-go-builder

ARG AMNEZIAWG_GO_VERSION=v3.1.20260828
ARG AMNEZIAWG_TOOLS_VERSION=v3.1.20260812
RUN git clone --depth 1 --branch "${AMNEZIAWG_GO_VERSION}" \
        https://github.com/amnezia-vpn/amneziawg-go.git /src/amneziawg-go && \
    make -C /src/amneziawg-go && \
    git clone --depth 1 --branch "${AMNEZIAWG_TOOLS_VERSION}" \
        https://github.com/amnezia-vpn/amneziawg-tools.git /src/amneziawg-tools && \
    make -C /src/amneziawg-tools/src

FROM python:3.10-bookworm

RUN apt-get update && \
    apt-get install -y \
        bubblewrap \
        curl \
        git \
        build-essential \
        iproute2 \
        openresolv && \
    rm -rf /var/lib/apt/lists/*

COPY --from=amneziawg-go-builder /src/amneziawg-go/amneziawg-go /usr/local/bin/amneziawg-go
COPY --from=amneziawg-go-builder /src/amneziawg-tools/src/wg /usr/local/bin/awg
COPY --from=amneziawg-go-builder /src/amneziawg-tools/src/wg-quick/linux.bash /usr/local/bin/awg-quick
COPY start-codex-container.sh /usr/local/bin/start-codex-container
RUN chmod 0755 /usr/local/bin/amneziawg-go /usr/local/bin/awg \
        /usr/local/bin/awg-quick /usr/local/bin/start-codex-container

RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

RUN groupadd -g 1000 codex && \
    useradd -u 1000 -g 1000 -d /root -s /bin/bash -M codex

# Keep globally installed npm tools outside the system prefix so the
# unprivileged runtime user can apply Codex's built-in updates.
ENV NPM_CONFIG_PREFIX=/opt/npm-global
ENV PATH=/opt/npm-global/bin:${PATH}

RUN mkdir -p "${NPM_CONFIG_PREFIX}" && \
    npm install -g @openai/codex && \
    chown -R codex:codex "${NPM_CONFIG_PREFIX}"

WORKDIR /dev_projects

CMD ["/usr/local/bin/start-codex-container"]
