# Provenance Testing Action
This action setups up Provenance in a docker container and allows the user to pass in both the version of provenance to use as well as a test script.  After Provenance is up running the test script is executed.  This allows testing of any of Provenance's features inside of this docker container as part of a github release process.

## Use as a github action
This action is published and can be brought into any project.
For an example of this in use look at [this repository's test workflow](https://github.com/provenance-io/provenance-testing-action/blob/main/.github/workflows/test.yml#L24)

---

### Smart Contract Actions

#### Testing

- #### With a released version of Provenance
    ```yaml
    - name: Smart Contract Test setup
        uses: provenance-io/provenance-testing-action@v1.2.0
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          provenance_version: "v1.16.0"
          test_script: "./scripts/name_test.sh"
    ```

- #### With a development version of Provenance
    Note: `provenance_version` is a branch which has an associated `Pull Request` and a **successful** run of the [Provenance Build and Release action](https://github.com/provenance-io/provenance/actions/workflows/release.yml)
    ```yaml
    - name: Smart Contract Test setup
        uses: provenance-io/provenance-testing-action@v1.2.0
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          provenance_version: "issue/new-feature"
          test_script: "./scripts/name_test.sh"
    ```

#### Using provided initial data for Provenance
```yaml
- name: Smart Contract Test setup
    uses: provenance-io/provenance-testing-action@v1.2.0
    with:
      github_token: ${{ secrets.GITHUB_TOKEN }}
      provenance_version: "v1.16.0"
      init_data: "./smart_contract_action/test/init_data"
      test_script: "./smart_contract_action/scripts/name_test.sh"
```

---

### Configuration

| Key                  |  Type   |   Required   | Description                                                                                                                                                                                              |
|----------------------|:-------:|:------------:|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `github_token`       |  token  | **Required** | set to `${{ secrets.GITHUB_TOKEN }}`                                                                                                                                                                     |
| `provenance_version` | string  | **Required** | Version of Provenance to test, either a release or a branch                                                                                                                                              |
| `init_data`          | string  |  *Optional*  | The directory that contains the initial seed data for Provenance. It should contain the `config`, `data`, and `keyring-test` directories. Example: [init_data](smart-contract-action%2Ftest%2Finit_data) |
| `test_script`        | string  |  *Optional*  | Script used to run tests after provenance has been setup and is running                                                                                                                                  |
