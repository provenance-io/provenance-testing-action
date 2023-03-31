#!/bin/bash -e

# This script is a sanity check that stores the tutorial smart contract
PROV_CMD="provenanced"

# Run the contract
"$PROV_CMD" tx wasm store ./smart-contract-action/test/provwasm_tutorial.wasm \
  	--from=validator \
    --keyring-backend="test" \
    --chain-id="testing" \
    --gas=auto \
    --gas-prices="1905nhash" \
	  --gas-adjustment=1.5 \
    --broadcast-mode=block \
    --yes \
    -t
