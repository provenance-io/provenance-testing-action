# Provenance Testing Action
A Github action to simplify testing with the Provenance blockchain.

### Summary
This action setups up Provenance in a docker container and allows the user to pass in both the version of provenance to use as well as a test script.  After Provenance is running the test script is run.  This allows testing of any of provenance's features inside of this docker container as part of a github release process.

### Use
For an example of this in use look at the smart contract tests in `provwasm` [link](https://github.com/provenance-io/provwasm/blob/main/.github/workflows/test.yml#L55)
