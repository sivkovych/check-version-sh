# check-version-sh

[![Marketplace](https://img.shields.io/badge/version-1.1.2-blue)](https://github.com/marketplace/actions/check-version-sh)

Action functionality:

- Ensure version changes regardless base branch on pull request
- Ensure version changes regardless previous commit on push

## Changelog

<details>
<summary>Full Changelog</summary>

- **1.1.0**
  - Removed `README.md` standard option
  - Add labels to the version-containing files
  - Add `readme-badge` check
  - Add `readme-changelog` check
- **1.1.1**
- **2.213.2**
- **AsdasD**
  - asdasdasd
  - asdasdasd

</details>

- **1.1.1**
- **2.213.2**
- **2.2.3**
  - asdasdasd
  - asdasdasd
- **2.2.4**
  - asdasdasd
  - asdasdasd
- **2.2.5**
  - asdasdasd
  - asdasdasd

## Limitations

- Currently supported files
    - `pom.xml` - check for the `<version>\d.\d.\d</version>`
    - `package.json` - check for the `"version": "\d.\d.\d""` version
    - `README.md`
      - `readme-badge` - check for the `https://*.+/badge/version-\d.\d.\d`
      - `readme-changelog` - check for the `- **\d.\d.\d**`
- Currently supported numeric versions only
- MacOS implementation works through installing `ggrep` through `homebrew`, hence it works slower than on Ubuntu

## Usage

Make sure to check out first since the script needs some files to check.   
check-version-sh action will exit with success code `0` if check

- for all specified (with optional `check-only-for` option) files were successful
- for at least one present (from all supported version files) file was successful

And with fail code `1` if check

- for any specified files (with optional `check-only-for` option) fails
- for at least one present (from all supported version files) file fails
- if none of the files (from all supported version files) is present in the `git diff`

### Parameters

See [action.yml](action.yml) or [info.sh](src/check-version/info.sh).

- `log-level` - logging level that will be used by the shell script
  - TRACE
  - DEBUG
  - INFO
  - WARN
  - ERROR
- `check-only-for` - a list of coma separated files to check for (since GitHub Actions does not support array inputs
  yet). Do not insert space after coma, or the list will be parsed as a separate arguments.

### Sample Configuration

```yaml
jobs:
  # ...
  steps:
    # ...
    - name: Check Version Changes
      uses: sivkovych/check-version-sh@v1.1
      with:
        log-level: "INFO"
        check-only-for: "pom.xml,package.json"
    # ...
```
