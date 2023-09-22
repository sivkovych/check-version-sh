#section Public API
check_version::apply() {
    local version_file="${1}"
    local ref="${2}"
    # shellcheck source=./version-in/*.sh
    source "${version_file}"
    local file_name
                    file_name=$(version::file_name)
    local check_label
                    check_label=$(version::label)
    log::debug "Looking for [${file_name}] in git diff"
    local path
               path=$(git::diff_files "${ref}" | local::grep "^${file_name}$")
    if [ -z "${path}" ]; then
        log::debug "Cannot find [${file_name}] in changed files"
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
        log::error "New version for [${check_label}] is empty or non-numeric"
        return 1
    elif [ -z "${old_version}" ] && [ -z "${new_version}" ]; then
        log::error "No changed version for [${check_label}]"
        return 1
    elif [ -z "${old_version}" ] && [ -n "${new_version}" ]; then
        log::info "Version [${check_label}] was just added - [${new_version}]"
        return 0
    elif [ -z "${old_version}" ] || [ -z "${new_version}" ]; then
        log::error "[${check_label}] was changed but version is the same"
        return 1
    fi
    log::info "Version changed from [${old_version}] to [${new_version}] for [${check_label}]"
    local sorted_parts
                        # shellcheck disable=SC2207
                        sorted_parts=($(util::sorted_parts "${PROJECT_DIR}"))
    local differences=()
    for part in "${sorted_parts[@]}"; do
        # shellcheck source=./part/*.sh
        source "${part}"
        local label
                    label="$(part::label)"
        local index=$(($(part::index) + 1))
        local old_part
                       old_part=$(string::element "${old_version}" "${index}")
        log::debug "Identified old [${label}] -- [${old_part}]"
        local new_part
                       new_part=$(string::element "${new_version}" "${index}")
        log::debug "Identified new [${label}] -- [${new_part}]"
        local difference=$((new_part - old_part))
        differences+=("${label}")
        differences+=("${difference}")
    done
    log::debug "Calculated differences: [${differences[*]}]"
    check_version::_comparison "${differences[@]}"
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
