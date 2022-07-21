#!/bin/bash -e

# This script stores, instantiates and executes the tutorial smart contract
PROV_CMD="./bin/provenanced"

export node0=$("$PROV_CMD" keys show -a validator --keyring-backend test -t)

# Run the contract
"$PROV_CMD" tx wasm store ./smart-contract-action/test/provwasm_tutorial.wasm \
  	--from="$node0" \
    --keyring-backend="test" \
    --chain-id="testing" \
    --gas=auto \
    --gas-prices="1905nhash" \
	  --gas-adjustment=1.5 \
    --broadcast-mode=block \
    --yes \
    -t