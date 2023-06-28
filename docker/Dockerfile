FROM docker.io/datree/datreeci:latest as datree

FROM docker.io/alpine/k8s:1.26.6

COPY --from=datree /usr/local/bin/datree /usr/local/bin/datree

ENTRYPOINT [""]