#!/bin/bash
#section Aliases
shopt -s expand_aliases
if [[ "${OSTYPE}" =~ ^darwin ]]; then
    alias local_grep='ggrep'
elif [[ "${OSTYPE}" =~ ^linux ]]; then
    alias local_grep='grep'
fi
#endsection
#section Imports
current_dir=$(dirname "${BASH_SOURCE[0]}")
source "${current_dir}"/util.sh
source "${current_dir}"/log.sh
source "${current_dir}"/info.sh
#endsection
#section Parameter Parsing
parameters="${*}"
while [ ${#} -gt 0 ]; do
    if [[ ${1} == "--help" ]]; then
        get_description
        get_usage
        exit 0
    elif [[ ${1} == "--"* ]]; then
        variable="${1/--/}"
        declare "${variable//-/_}"="${2}"
        shift
    fi
    shift
done
if [ -z "${branch_ref}" ] && [ -z "${commit_ref}" ]; then
    get_fail_message "Missing required parameters [--branch-ref] or [--commit-ref]"
    get_usage
    exit 1
fi
#endsection
#section Set Up
declare check_only_for
declare branch_ref
declare commit_ref
configure_log "${log_level:-"info"}"
debug "Configured log level to [${log_level}]"
debug "Received parameters: [${parameters}]"
#endsection
#section Core Logic
get_comparison() {
    while [ ${#} -gt 0 ]; do
        local label="${1}"
        local difference="${2}"
        if [ "${difference}" -gt 0 ]; then
            info "[${label}] incremented by [${difference}]"
            return 0
        elif [ "${difference}" -eq 0 ]; then
            info "[${label}] unchanged"
            shift 2
        else
            info "[${label}] decremented by [${difference/-/}]"
            return 1
        fi
    done
}
function check_version() {
    local version_file="${1}"
    local ref="${2}"
    # shellcheck source=./version-file/*.sh
    source "${version_file}"
    local file_name
                    file_name=$(get_name)
    debug "Looking for [${file_name}] in git diff"
    local path
               path=$(git diff --name-only "${ref}" | local_grep "^${file_name}$")
    if [ -z "${path}" ]; then
        debug "Cannot find [${file_name}] in changed files"
        return 66
    fi
    debug "Found [${path}] in git diff"
    local git_diff
                   git_diff=$(git diff "${ref}" "${path}" | sed -e 's| ||g')
    local old_version
                       old_version=$(get_old_version "$git_diff")
    local new_version
                      new_version=$(get_new_version "$git_diff")
    if [ -n "${old_version}" ] && [ -z "${new_version}" ]; then
        error "New version in [${file_name}] is empty or non-numeric"
        return 1
    elif [ -z "${old_version}" ] && [ -z "${new_version}" ]; then
        error "No changed version in [${file_name}]"
        return 1
    elif [ -z "${old_version}" ] && [ -n "${new_version}" ]; then
        info "File [${file_name}] was just added with the version [${new_version}]"
        return 0
    elif [ -z "${old_version}" ] || [ -z "${new_version}" ]; then
        error "[${file_name}] was changed but version is the same"
        return 1
    fi
    info "Version changed from [${old_version}] to [${new_version}] in [${file_name}]"
    local sorted_parts
                        # shellcheck disable=SC2207
                        sorted_parts=($(get_sorted_parts "${current_dir}"))
    local differences=()
    for part in "${sorted_parts[@]}"; do
        # shellcheck source=./part/*.sh
        source "${part}"
        local label
                    label="$(get_label)"
        local index=$(($(get_index) + 1))
        local old_part
                       old_part=$(get_element "${old_version}" "${index}")
        debug "Identified old [${label}] -- [${old_part}]"
        local new_part
                       new_part=$(get_element "${new_version}" "${index}")
        debug "Identified new [${label}] -- [${new_part}]"
        local difference=$((new_part - old_part))
        differences+=("${label}")
        differences+=("${difference}")
    done
    debug "Calculated differences: [${differences[*]}]"
    get_comparison "${differences[@]}"
    return "${?}"
}
#endsection
#section Execution
if [ -n "${branch_ref}" ] || [ "${branch_ref}" != "$(null)" ]; then
    branch="$(git branch --list | local_grep "${branch_ref}")"
    if [ -n "${branch}" ]; then
        debug "Fetching from [origin ${branch_ref}]"
        git fetch -q -f origin "${branch_ref}"
    else
        fail "Branch [${branch_ref}] does not exist"
    fi
else
    if [ -n "${commit_ref}" ] || [ "${commit_ref}" != "$(null)" ]; then
        commit="$(git rev-list --all | local_grep "${commit_ref}")"
        if [ -z "${commit}" ]; then
            fail "Commit [${commit_ref}] does not exist"
        fi
    fi
fi
check_results=()
for version_file in "${current_dir}"/version-file/*.sh; do
    debug "Checking changes for [${version_file}]"
    if [ -n "${check_only_for}" ] && [[ "${version_file}" != *"${check_only_for/\./-}.sh" ]]; then
        debug "[check-only-for ${check_only_for}] option is set - skipping [${version_file}] check"
        continue
    fi
    check_version "${version_file}" "${branch_ref:-${commit_ref}}"
    check_result="${?}"
    check_results+=("${check_result}")
    debug "Received exit code from version check [${check_result}]"
done
debug "Version Checks exit codes: [${check_results[*]}]"
if contains 1 "${check_results[@]}"; then
    fail "Version Check failed"
fi
if every 66 "${check_results[@]}"; then
    fail "No changed/supported version files found"
fi
debug "Exit code [0]"
exit 0
#endsection
