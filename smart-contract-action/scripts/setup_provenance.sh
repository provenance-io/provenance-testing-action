#!/bin/bash -e

INIT_DATA=$1
TEST_SCRIPT=$2
GENERATE_PROPOSALS=$3
WASM_PATH=$4

# this will create a folder with both provenance and libwasm
unzip "provenance-linux-amd64-*.zip"

mkdir ./build

PROV_CMD="./bin/provenanced"
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

  # create an account to generate the proposals since the sequence will always be 1
  "$PROV_CMD" keys add proposal_generator --keyring-backend test --testnet --hd-path "44'/1'/0'/0/0"

  # generate and sanitize the store code proposal
  "$PROV_CMD" tx gov submit-proposal wasm-store "$WASM_PATH" \
    --title "title" \
    --description "description" \
    --run-as "$("$PROV_CMD" keys show -a proposal_generator --keyring-backend test --testnet)" \
    --testnet \
    --instantiate-only-address "$("$PROV_CMD" keys show -a proposal_generator --keyring-backend test --testnet)" \
    --from "$("$PROV_CMD" keys show -a proposal_generator --keyring-backend test --testnet)" \
    --generate-only \
    --sequence 1 | jq '.body.messages[0]' | jq -f /scripts/governance/wasm-store-filter.jq > wasm-store-proposal.json

  # generate and sanitize the instantiate code proposal
  "$PROV_CMD" tx gov submit-proposal instantiate-contract 1 {} \
    --title "title" \
    --description "description" \
    --label "label" \
    --run-as "$("$PROV_CMD" keys show -a proposal_generator --keyring-backend test --testnet)" \
    --admin "$("$PROV_CMD" keys show -a proposal_generator --keyring-backend test --testnet)"   --testnet \
    --from "$("$PROV_CMD" keys show -a proposal_generator --keyring-backend test --testnet)" \
    --generate-only \
    --sequence 1 | jq '.body.messages[0]' | jq -f /scripts/governance/instantiate-contract-filter.jq > instantiate-contract-proposal.json

  # generate and sanitize the migrate code proposal
  "$PROV_CMD" tx gov submit-proposal migrate-contract \
    "$("$PROV_CMD" keys show -a proposal_generator --keyring-backend test --testnet)" 1 {} \
    --title title --description description \
    --from "$("$PROV_CMD" keys show -a proposal_generator --keyring-backend test --testnet)" \
    --generate-only \
    --testnet --sequence 1 | jq '.body.messages[0]' | jq -f /scripts/governance/migrate-contract-filter.jq > migrate-contract-proposal.json
fi