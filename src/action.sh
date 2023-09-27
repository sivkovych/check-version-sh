#!/bin/bash
#section Imports
readonly PROJECT_DIR="$(dirname "${0}")/check-version"
source "${PROJECT_DIR}"/alias.sh
source "${PROJECT_DIR}"/string.sh
source "${PROJECT_DIR}"/array.sh
source "${PROJECT_DIR}"/util.sh
source "${PROJECT_DIR}"/git.sh
source "${PROJECT_DIR}"/log.sh
source "${PROJECT_DIR}"/info.sh
source "${PROJECT_DIR}"/check-version.sh
#endsection
#section Parameter Parsing
readonly old_ifs="${IFS}"
readonly input_arguments="${*}"
IFS=$'\n'
for argument in ${input_arguments//--/$'\n'}; do
    IFS=$' '
    for arg in ${argument}; do
        args+=("$(string::get_separated "${arg}")")
    done
    if [ -z "${args[*]}" ]; then
        continue
    fi
    key="${args[0]//-/_}"
    case "${key}" in
    "help")
        info::get_description
        info::get_usage
        exit 0
        ;;
    "branch_ref") declare -r branch_ref="${args[1]}" ;;
    "commit_ref") declare -r commit_ref="${args[1]}" ;;
    "log_level") declare -r log_level="${args[1]}" ;;
    "check_only_for")
        arr=("${args[@]:1}")
        eval declare -ar check_only_for=\("${arr[*]}"\)
        ;;
    esac
    args=()
done
IFS="${old_ifs}"
#endsection
#section Set Up
log::configure_log "${log_level:-"info"}"
log::debug "Configured log level to [${log_level}]"
log::trace "Input arguments - [${input_arguments}]"
log::debug "$(info::get_parameters \
    "branch_ref" "${branch_ref}"\
    "commit_ref" "${commit_ref}"\
    "log_level" "${log_level}"\
    "check_only_for" "${check_only_for[*]}")"
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
    # shellcheck source=./version-in/*.sh
    source "${version_file}"
    check_label=$(version::label)
    log::debug "Checking changes for [${check_label}]"
    if array::not_contains "${check_label}" "${check_only_for[@]}" && [ -n "${check_only_for[*]}" ]; then
        log::debug "[check-only-for ${check_only_for[*]}] option is set - skipping [${check_label}] check"
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
