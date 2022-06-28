#!/bin/bash -e

# this will create a folder with both provenance and libwasm
unzip "provenance-linux-amd64-*.zip"

mkdir ./build

PROV_CMD="./bin/provenanced"
PIO_HOME="./build"
export PIO_HOME

if [ ! -d "$PIO_HOME/config" ]; then
    "$PROV_CMD" -t init --chain-id=testing testing
    "$PROV_CMD" -t keys add validator --keyring-backend test
    "$PROV_CMD" -t add-genesis-root-name validator pio --keyring-backend test
    "$PROV_CMD" -t add-genesis-root-name validator pb --restrict=false \
		--keyring-backend test
    "$PROV_CMD" -t add-genesis-root-name validator io --restrict \
		--keyring-backend test
    "$PROV_CMD" -t add-genesis-root-name validator provenance \
		--keyring-backend test
    "$PROV_CMD" -t add-genesis-account validator 100000000000000000000nhash \
		--keyring-backend test
    "$PROV_CMD" -t gentx validator 1000000000000000nhash \
		--keyring-backend test --chain-id=testing
    "$PROV_CMD" -t add-genesis-marker 100000000000000000000nhash --manager \
		validator --access mint,burn,admin,withdraw,deposit \
		--activate --keyring-backend test
    "$PROV_CMD" -t collect-gentxs
fi
nohup "$PROV_CMD" -t start &>/dev/null &

echo "Sleeping for provenance to start up"
sleep 10s

# execute the script test that was passed in as an argument
echo "Executing test..."

$2

echo "Test complete"

if [ "$GENERATE_PROPOSALS" ]; then
    echo "Generating proposals..."

    # generate the store code proposal
    store_code_proposal='{"store_code_proposal":"hello_store"}'
    echo "::set-output name=store_code_proposal::$store_code_proposal"

    # generate the instantiate code proposal
    instantiate_code_proposal='{"instantiate_code_proposal":"hello_instantiate"}'
    echo "::set-output name=instantiate_code_proposal::$instantiate_code_proposal"

    # generate the migrate code proposal
    migrate_code_proposal='{"migrate_code_proposal":"hello_migrate"}'
    echo "::set-output name=migrate_code_proposal::$migrate_code_proposal"
fi