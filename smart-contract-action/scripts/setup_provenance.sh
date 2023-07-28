#!/bin/bash -e

INIT_DATA=$1
TEST_SCRIPT=$2
GENERATE_PROPOSALS=$3
WASM_PATH=$4

# this will create a folder with both provenance and libwasm
cd /scratch
unzip "provenance-linux-amd64-*.zip" -d /usr

mkdir ./build

PROV_CMD="provenanced"
PIO_HOME="./build"
export PIO_HOME
export PROV_CMD

if [ "$INIT_DATA" != false ]; then
    # place the initial config data in the default location
    echo "Setting initial data..."

    cp -r "$INIT_DATA"/* $PIO_HOME
fi

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
sleep 5s

"$PROV_CMD" -t q marker holding nhash

if [ "$TEST_SCRIPT" != false ]; then
    # execute the script test that was passed in as an argument
    echo "Executing test..."

    $TEST_SCRIPT

    echo "Test complete"
fi

if [ "$GENERATE_PROPOSALS" != false ]; then
    printf "\n\nGenerating proposals...\n\n"

    $(base64 --wrap=0 $WASM_PATH > wasm_base64)

    # generate and sanitize the store code proposal
    awk 'NR==FNR{a=a""$0"\n";next} {while (match($0, /\$BYTE_CODE/)) {printf "%s", substr($0, 1, RSTART-1) a; $0 = substr($0, RSTART+RLENGTH)}; print}' wasm_base64 /scripts/templates/governance/store/draft_proposal.json > temp_store_proposal
    mv temp_store_proposal /scripts/templates/governance/store/draft_proposal.json
fi
