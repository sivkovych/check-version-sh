# check-version-sh

[![Marketplace](https://img.shields.io/badge/version-1.5.0-blue)](https://github.com/marketplace/actions/check-version-sh)

Action functionality:

- Ensure version changes regardless base branch on pull request
- Ensure version changes regardless previous commit on push

## Limitations

- Currently supported options
    - `pom.xml` - check for the first `<version>...</version>`
    - `package.json` - check for the first `"version": "..."` version
    - `package-lock.json` - check for the first `"version": "..."` version
    - `README.md`
        - `readme-version-badge` - check for the `https://*.+/badge/version-...` version
        - `readme-nexus-badge` - check for the `https://*.+/badge/nexus-...` version
        - `readme-changelog` - check for the `- **...**` version
        - `readme-action` - check for the `<current-repo-name>@...` version
- Currently supported numeric or numeric with preceding letter versions only
- MacOS implementation works through installing `ggrep` through `homebrew`, hence it works slower than on Ubuntu

## Changelog

- **1.1.0**
    - Removed `README.md` standard option
    - Add labels to the version-containing files
    - Add `readme-badge` check
    - Add `readme-changelog` check
- **1.2.0**
    - Add `package-lock.json` file support
    - Add `readme-action` label support
    - Fix digit regexp for the `readme-badge` label
- **1.2.1**
    - Fix regexp for the old version in the `readme-changelog` version
    - Fix `change-only-for` array-split
    - Change Git current branch retrieval to support Git version < 2.22
    - Fix label for the `readme-action` label
- **1.3.0**
    - Rename `readme-badge` option to `readme-version-badge`
    - Add `readme-nexus-badge` option
    - Add support of coma/space separated string array as an input argument
    - Modified info messages
    - Move aliases initialization to a separate file
    - Move arguments parsing to a separate file
- **1.3.1**
    - Add list of failed files to the log
    - Add successful message to the log
- **1.3.2**
    - Fix failed files logging
    - Add missing files log message
- **1.3.3** - Fix regexp to work with the preceding letter
- **1.4.0**
    - Add support for more than 3 version parts
    - Now parsing different delimiters in a single version
- **1.5.0** - Added `src/check.sh` as a runnable program 

## Usage

Make sure to check out first since the script needs some files to check.   
check-version-sh action will exit with success code `0` if check

- for all specified (with optional `check-only-for` option) files were successful
- for at least one present (from all supported version files) file was successful

And with fail code `1` if check

- for any specified files (with optional `check-only-for` option) fails
- for at least one present (from all supported version files) file fails
- if none of the files (from all supported version files) is present in the `git diff`

### YAML Parameters

See [action.yml](action.yml) or [info.sh](src/check-version/info.sh).

- `log-level` - logging level that will be used by the shell script
    - TRACE
    - DEBUG
    - INFO
    - WARN
    - ERROR
- `check-only-for` - a list of coma or space separated labels to check for    
  (since GitHub Actions does not support yaml array inputs yet)

### Sample Configuration

```yaml
jobs:
  # ...
  steps:
    # ...
    - name: Check Version Changes
      uses: sivkovych/check-version-sh@v1.5.0
      with:
        log-level: "INFO"
        check-only-for: "pom.xml, package.json, readme-version-badge"
    # ...
```
