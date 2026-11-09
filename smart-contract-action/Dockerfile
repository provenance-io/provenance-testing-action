# Docker file for testing provwasm
FROM debian:bookworm-slim
# install apt-utils first
RUN apt-get update -y
RUN apt-get install -y apt-utils
RUN apt-get upgrade -y && \
    apt-get install -y curl jq libleveldb-dev zip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/

COPY --chown=0:0 ./scripts /scripts

# Initialize provenance to run with the default node configuration
ENTRYPOINT ["/scripts/setup_provenance.sh"]