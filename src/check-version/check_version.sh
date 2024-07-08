#section Public API
check_version::is_valid_file() {
    local ref="${1}"
    local file_name="${2}"
    local file_label="${3:-${file_name}}"
    local path
               path=$(git::diff_files "${ref}" | local::grep "^${file_name}$")
    if [ -z "${path}" ]; then
        log::debug "Cannot find [${file_label}] in changed files"
        return 66
    fi
    log::debug "Found [${path}] in git diff"
    local git_diff
                   git_diff=$(git::diff "${ref}" "${path}" | sed -e 's| ||g')
    local old_version
                       old_version=$(version::old "$git_diff")
    local new_version
                      new_version=$(version::new "$git_diff")
    log::trace "Old version -- [${old_version}]"
    log::trace "New version -- [${new_version}]"
    if [ -n "${old_version}" ] && [ -z "${new_version}" ]; then
        log::error "New version for [${file_label}] is empty or non-numeric"
        return 1
    elif [ -z "${old_version}" ] && [ -z "${new_version}" ]; then
        log::error "No changed version for [${file_label}]"
        return 1
    elif [ -z "${old_version}" ] && [ -n "${new_version}" ]; then
        log::info "Version [${file_label}] was just added - [${new_version}]"
        return 0
    elif [ -z "${old_version}" ] || [ -z "${new_version}" ]; then
        log::error "[${file_label}] was changed but version is the same"
        return 1
    fi
    log::info "Version changed from [${old_version}] to [${new_version}] for [${file_label}]"
    local old_version_arr
                            # shellcheck disable=SC2207
                            old_version_arr=($(string::get_separated "$(version::old "$git_diff")"))
    local new_version_arr
                            # shellcheck disable=SC2207
                            new_version_arr=($(string::get_separated "$(version::new "$git_diff")"))
    log::trace "Old version size: [${#old_version_arr[@]}]"
    log::trace "New version size: [${#new_version_arr[@]}]"
    log::trace "Iterating over new version: [${new_version_arr[*]}]"
    local sorted_parts
                        # shellcheck disable=SC2207
                        sorted_parts=($(util::sorted_parts "${PROJECT_DIR}"))
    local differences=()
    for ((i=0; i < "${#new_version_arr[@]}"; i++)); do
        local new_version_element
                    new_version_element="$(number::format "${new_version_arr[$i]}")"
        local part
                    part="${sorted_parts[$i]}"
        local label
        if [ -n "${part}" ]; then
            # shellcheck source=./part/*.sh
            source "${part}"
            label="$(part::label)"
        else
            label="ADDITIONAL VERSION"
        fi
        log::trace "Element [${new_version_element}] is [${label}] part with index [${i}]"
        local old_version_element
                        old_version_element="$(number::format "${old_version_arr[$i]}")"
        local difference=$((new_version_element - old_version_element))
        log::trace "Difference between [${new_version_element}] and [${old_version_element}] is [${difference}]"
        differences+=("${label}")
        differences+=("${difference}")
    done
    log::debug "Calculated differences in [${file_label}]: [${differences[*]}]"
    check_version::_comparison "${differences[@]}"
    return "${?}"
}
check_version::apply() {
    local version_file="${1}"
    local ref="${2}"
    # shellcheck source=./version-in/*.sh
    source "${version_file}"
    local file_name
                    file_name=$(version::file_name)
    local file_label
                    file_label=$(version::label)
    check_version::is_valid_file "${ref}" "${file_name}" "${file_label}"
    return "${?}"
}
#endsection
#section Private API
check_version::_comparison() {
    while [ ${#} -gt 0 ]; do
        local label="${1}"
        local difference="${2}"
        if [ "${difference}" -gt 0 ]; then
            log::info "[${label}] incremented by [${difference}]"
            return 0
        elif [ "${difference}" -eq 0 ]; then
            log::info "[${label}] unchanged"
            shift 2
        else
            log::info "[${label}] decremented by [${difference/-/}]"
            return 1
        fi
    done
}
#endsection
