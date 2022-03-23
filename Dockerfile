# Docker file for testing provwasm
FROM golang:1.17-buster as build
RUN apt-get update -y && apt-get upgrade -y && apt-get install -y libleveldb-dev
RUN apt-get install -y unzip

COPY --chown=0:0 ./scripts ./scripts
COPY --chown=0:0 ./scripts/setup_provenance.sh /setup_provenance.sh

# install jq for parsing output of queries when running Provenance
RUN curl -o /usr/local/bin/jq http://stedolan.github.io/jq/download/linux64/jq && \
  chmod +x /usr/local/bin/jq

# Initialize provenance to run with the default node configuration
ENTRYPOINT ["/setup_provenance.sh"]