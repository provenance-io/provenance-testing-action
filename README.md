# Provenance Testing Action
A Github action to simplify testing with the Provenance blockchain.

### Summary
This action setups up Provenance in a docker container and allows the user to pass in both the version of provenance to use as well as a test script.  After Provenance is up running the test script is executed.  This allows testing of any of Provenance's features inside of this docker container as part of a github release process.

### Use as a github action
For an example of this in use look at the smart contract tests in `provwasm` [link](https://github.com/provenance-io/provwasm/blob/main/.github/workflows/test.yml#L55)

This action is published and can be brought into any project with the following:

```yaml
- name: Smart Contract Test setup
    uses: provenance-io/provenance-testing-action@v1.0.0
    with:
      provenance_version: "v1.8.0"
      test_script: "./scripts/name_test.sh"
```

### Use as a docker image
The docker image is deployed at: https://hub.docker.com/r/provenanceio/provenance-testing-action

This image can be downloaded and run.  However to do so, instead of just running the image you will need to pull the image, create a container, copy the test script and any files it needs into the container and then run it like the following pulled from the `Makefile` in [Provwasm](https://github.com/provenance-io/provwasm)

```Makefile
.PHONY: test-tutorial
test-tutorial: tutorial optimize-tutorial
	docker rm -f test_container || true
	docker pull provenanceio/provenance-testing-action
	docker create --name test_container provenanceio/provenance-testing-action --entrypoint	"/scripts/tutorial_test.sh" "$(PROVENANCE_TEST_VERSION)"
	docker cp ./scripts test_container:/scripts
	docker cp ./contracts test_container:/go/contracts
	docker start test_container
```