FROM bridgecrew/checkov:2.3.243

RUN apt-get update && \
    apt-get install -y curl && \
    rm -rf /var/cache/apt/*

RUN curl -fsSL -o - https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash -

ENTRYPOINT [""]