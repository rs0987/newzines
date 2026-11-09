FROM debian:trixie-slim
RUN apt-get update && apt-get install -y curl git ripgrep ca-certificates \
 && rm -rf /var/lib/apt/lists/*
RUN useradd -m dev
USER dev
RUN curl -fsSL https://claude.ai/install.sh | bash
ENV PATH="/home/dev/.local/bin:${PATH}"
WORKDIR /workspace
