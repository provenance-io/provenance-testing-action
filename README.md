# Provenance Testing Action
A Github action to simplify testing with the Provenance blockchain.

## Summary
This action setups up Provenance in a docker container and allows the user to pass in both the version of provenance to use as well as a test script.  After Provenance is up running the test script is executed.  This allows testing of any of Provenance's features inside of this docker container as part of a github release process.

## Use as a github action
This action is published and can be brought into any project.
For an example of this in use look at the smart contract tests in `provwasm` [link](https://github.com/provenance-io/provwasm/blob/main/.github/workflows/test.yml#L55)

---

### Smart Contract Actions

#### Testing

- #### With a released version of Provenance
    ```yaml
    - name: Smart Contract Test setup
        uses: provenance-io/provenance-testing-action@v1.1.0
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          provenance_version: "v1.11.1"
          test_script: "./scripts/name_test.sh"
    ```

- #### With a development version of Provenance
    Note: `provenance_version` is a branch which has an associated `Pull Request` and a **successful** run of the [Provenance Build and Release action](https://github.com/provenance-io/provenance/actions/workflows/release.yml)
    ```yaml
    - name: Smart Contract Test setup
        uses: provenance-io/provenance-testing-action@v1.1.0
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          provenance_version: "issue/new-feature"
          test_script: "./scripts/name_test.sh"
    ```

#### Generating governance proposals
```yaml
- name: Smart Contract Test setup
    uses: provenance-io/provenance-testing-action@v1.1.0
    with:
      github_token: ${{ secrets.GITHUB_TOKEN }}
      provenance_version: "v1.11.1"
      test_script: "./scripts/name_test.sh"
```

---

### Configuration

| Key                  |  Type   |   Required   | Description                                                             |
|----------------------|:-------:|:------------:|-------------------------------------------------------------------------|
| `github_token`       |  token  | **Required** | set to `${{ secrets.GITHUB_TOKEN }}`                                    |
| `provenance_version` | string  | **Required** | Version of Provenance to test, either a release or a branch             |
| `test_script`        | string  |  *Optional*  | Script used to run tests after provenance has been setup and is running |
| `generate_proposals` | boolean |  *Optional*  | Generate the store, instantiate, and migrate governance proposals       |
| `wasm_path`          | string  |  *Optional*  | Path to the smart contract wasm                                         |
