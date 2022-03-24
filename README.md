# Provenance Testing Action
A Github action to simplify testing with the Provenance blockchain.

### Summary
This action setups up Provenance in a docker container and allows the user to pass in both the version of provenance to use as well as a test script.  After Provenance is up running the test script is executed.  This allows testing of any of Provenance's features inside of this docker container as part of a github release process.

### Use
For an example of this in use look at the smart contract tests in `provwasm` [link](https://github.com/provenance-io/provwasm/blob/main/.github/workflows/test.yml#L55)

This action is published and can be brought into any project with the following:

```yaml
- name: Smart Contract Test setup
        uses: provenance-io/provenance-testing-action@v1.0.0-beta2
        id: tutorial
        with:
          provenance_version: "v1.8.0"
          test_script: "./scripts/name_test.sh"
```