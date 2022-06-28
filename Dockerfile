# Docker file for testing provwasm
FROM debian:buster-slim as run
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y curl jq libleveldb-dev zip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/

COPY --chown=0:0 ./scripts/setup_provenance.sh /setup_provenance.sh

# Initialize provenance to run with the default node configuration
ENTRYPOINT ["/setup_provenance.sh"]