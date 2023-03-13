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
source "${PROJECT_DIR}"/util.sh
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
if [ -z "${branch_ref}" ] && [ -z "${commit_ref_before}" ] && [ -z "${commit_ref_after}" ]; then
    util::get_fail_message "Missing required parameters [--branch-ref] or [--commit-ref-before] and [--commit-ref-after]"
    info::get_usage
    exit 1
fi
#endsection
#section Set Up
readonly check_only_for
readonly branch_ref
readonly commit_ref_before
readonly commit_ref_after
log::configure_log "${log_level:-"info"}"
log::debug "Configured log level to [${log_level}]"
log::debug "Received parameters: [${parameters}]"
#endsection
#section Execution
if [ -n "${branch_ref}" ]; then
    log::debug "Fetching from [origin ${branch_ref}]"
    git fetch -q -f origin "${branch_ref}"
else
    if [ -n "${commit_ref_before}" ] && [ -n "${commit_ref_after}" ]; then
        log::debug "GIT DIFF ${commit_ref_before}..${commit_ref_after}"
        git diff --name-only "${commit_ref_before}".."${commit_ref_after}"
        log::debug "GIT DIFF ${commit_ref_before}..HEAD"
        git diff --name-only "${commit_ref_before}"..HEAD
        log::debug "GIT BRANCH"
        git branch
#        log::debug "GIT FETCH"
#        git fetch -f origin
#        log::debug "GIT PULL"
#        git pull
#        log::debug "REV-LIST (git rev-list origin feature/readme-n-flow-n-all-specified-mandatory-check)"
#        git rev-list origin feature/readme-n-flow-n-all-specified-mandatory-check
#        log::debug "REV-LIST (git rev-list origin/feature/readme-n-flow-n-all-specified-mandatory-check)"
#        git rev-list origin/feature/readme-n-flow-n-all-specified-mandatory-check
#        log::debug "REV-LIST (git rev-list origin HEAD)"
#        git rev-list origin HEAD
#        log::debug "REV-LIST (git rev-list origin:HEAD)"
#        git rev-list origin:HEAD
#        log::debug "REV-LIST (git rev-list refs/remotes/origin/HEAD)"
#        git rev-list refs/remotes/origin/HEAD
#        log::debug "GIT LOG "
#        git log
#        log::debug "GIT DIFF"
#        git diff --name-only "${commit_ref}"~ "${commit_ref}"
#        commit="$(git rev-list --all origin | local::grep "${commit_ref}")"
#        if [ -z "${commit}" ]; then
#            log::fail "Commit [${commit_ref}] does not exist"
#        fi
    fi
fi
for version_file in "${PROJECT_DIR}"/version-in/*.sh; do
    log::debug "Checking changes for [${version_file}]"
    # shellcheck source=./version-in/*.sh
    source "${version_file}"
    if util::not_contains "$(version::file_name)" "${check_only_for[@]}" && [ -n "${check_only_for}" ]; then
        log::debug "[check-only-for ${check_only_for[*]}] option is set - skipping [${version_file}] check"
        continue
    fi
    #    check_version "${version_file}" "${branch_ref:-${commit_ref}}"
    #    check_result="${?}"
    #    check_results+=("${check_result}")
    #    log::debug "Received exit code from version check [${check_result}]"
done
log::debug "Version Checks exit codes: [${check_results[*]}]"
if util::contains 1 "${check_results[@]}"; then
    log::fail "Version Check failed"
fi
if ! util::every 0 "${check_results[@]}" && [ -n "${check_only_for}" ]; then
    log::fail "Not all specified file checks were successful"
fi
if util::every 66 "${check_results[@]}"; then
    log::fail "No changed/supported version files found"
fi
log::debug "Exit code [0]"
exit 0
