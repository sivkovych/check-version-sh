#!/bin/bash
#section Aliases
shopt -s expand_aliases
if [[ "${OSTYPE}" =~ ^darwin ]]; then
    if ! command -v ggrep >/dev/null; then
        brew install --quiet grep >/dev/null
    fi
    alias local::grep='ggrep'
elif [[ "${OSTYPE}" =~ ^linux ]]; then
    alias local::grep='grep'
fi
#endsection
#section Imports
readonly PROJECT_DIR="$(dirname "${0}")/check-version"
source "${PROJECT_DIR}"/string.sh
source "${PROJECT_DIR}"/array.sh
source "${PROJECT_DIR}"/util.sh
source "${PROJECT_DIR}"/git.sh
source "${PROJECT_DIR}"/log.sh
source "${PROJECT_DIR}"/info.sh
source "${PROJECT_DIR}"/check-version.sh
#endsection
#section Parameter Parsing
readonly parameters="${*}"
while [ ${#} -gt 0 ]; do
    if [[ "${1}" == "--help" ]]; then
        info::get_description
        info::get_usage
        exit 0
    elif [[ "${1}" == "--check-only-for" ]]; then
        # shellcheck disable=SC2206
        check_only_for=(${2/,/ })
        shift
    elif [[ "${1}" == "--"* ]]; then
        variable="${1/--/}"
        if [[ "${2}" == "--"* ]]; then
            declare "${variable//-/_}"=
            shift
        fi
        variable="${1/--/}"
        declare "${variable//-/_}"="${2}"
        shift
    fi
    shift
done
#endsection
#section Set Up
readonly check_only_for
readonly branch_ref
readonly commit_ref
log::configure_log "${log_level:-"info"}"
log::debug "Configured log level to [${log_level}]"
log::debug "Received parameters: [${parameters}]"
if [ -z "${branch_ref}" ] && [ -z "${commit_ref}" ]; then
    log::shallow_fail "Missing required parameters [--branch-ref] or [--commit-ref]"
    info::get_usage
    exit 1
fi
#endsection
#section Execution
ref="${branch_ref:-${commit_ref}}"
if ! git::fetch "${ref}"; then
    log::fail "Git Fetch failed for [${ref}]"
fi
for version_file in "${PROJECT_DIR}"/version-in/*.sh; do
    log::debug "Checking changes for [${version_file}]"
    # shellcheck source=./version-in/*.sh
    source "${version_file}"
    if array::not_contains "$(version::file_name)" "${check_only_for[@]}" && [ -n "${check_only_for}" ]; then
        log::debug "[check-only-for ${check_only_for[*]}] option is set - skipping [${version_file}] check"
        continue
    fi
    diff_ref=$([ -z "${branch_ref}" ] && echo "${commit_ref}" || echo "origin/${branch_ref}")
    check_version::apply "${version_file}" "${diff_ref}"
    check_result="${?}"
    check_results+=("${check_result}")
    log::debug "Received exit code from version check [${check_result}]"
done
log::debug "Version Checks exit codes: [${check_results[*]}]"
if array::contains 1 "${check_results[@]}"; then
    log::fail "Version Check failed"
fi
if array::every 66 "${check_results[@]}"; then
    log::fail "No changed/supported version files found"
fi
if ! array::every 0 "${check_results[@]}" && [ -n "${check_only_for}" ]; then
    log::fail "Not all specified file checks were successful"
fi
log::debug "Exit code [0]"
exit 0
