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
arg_chain_id="--chain-id=testing"
arg_keyring="--keyring-backend test"
export PIO_HOME
export PROV_CMD
export arg_chain_id
export arg_keyring

if [ "$INIT_DATA" != false ]; then
    # place the initial config data in the default location
    echo "Setting initial data..."

    cp -r "$INIT_DATA"/* $PIO_HOME
fi

if [ ! -d "$PIO_HOME/config" ]; then
    "$PROV_CMD" -t init testing --chain-id=testing $arg_chain_id
    "$PROV_CMD" -t keys add validator $arg_keyring
    "$PROV_CMD" -t genesis add-root-name validator pio $arg_keyring
    "$PROV_CMD" -t genesis add-root-name validator pb --restrict=false $arg_keyring
    "$PROV_CMD" -t genesis add-root-name validator io --restrict $arg_keyring
    "$PROV_CMD" -t genesis add-root-name validator provenance $arg_keyring
    "$PROV_CMD" -t genesis add-account validator 100000000000000000000nhash $arg_keyring
    "$PROV_CMD" -t genesis gentx validator 1000000000000000nhash $arg_chain_id $arg_keyring
    "$PROV_CMD" -t genesis add-marker 100000000000000000000nhash \
        --manager validator \
        --access mint,burn,admin,withdraw,deposit \
        $arg_keyring \
        --activate
    "$PROV_CMD" -t genesis add-default-market --denom nhash
    "$PROV_CMD" -t genesis collect-gentxs
    "$PROV_CMD" -t config set minimum-gas-prices "1905nhash"
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
