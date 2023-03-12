#section Public API
util::contains()  {
    local look_for=${1}
    shift
    local array=("${@}")
    for element in "${array[@]}"; do
        if [ "${element}" == "${look_for}" ]; then
            return 0
        fi
    done
    return 1
}
util::not_contains() {
    local look_for=${1}
    shift
    local array=("${@}")
    for element in "${array[@]}"; do
        if [ "${element}" == "${look_for}" ]; then
            return 1
        fi
    done
    return 0
}
util::every()  {
    local look_for="${1}"
    shift
    local array=("${@}")
    for element in "${array[@]}"; do
        if [ "${element}" != "${look_for}" ]; then
            return 1
        fi
    done
    return 0
}
util::get_delimiter() {
    echo "${1}" |
        local::grep -Po "[\W\D]" |
        sort |
        uniq --count |
        head -1 |
        sed -e 's| ||g;s|[0-9]||g'
}
util::get_element() {
    local delimiter
                     delimiter="$(util::get_delimiter "${1}")"
    echo "${1}" | cut -d"${delimiter}" -f"${2}"
}
util::get_fail_message() {
    printf "Script failed: %s\n\n" "${1}"
}
util::get_parts() {
    local current_dir="${1}"
    local parts=()
    for part in "${current_dir}"/part/*.sh; do
        parts+=("${part}")
    done
    echo "${parts[@]}"
}
util::get_sorted_parts() {
    local current_dir="${1}"
    local parts=()
    for part in "${current_dir}"/part/*.sh; do
        parts+=("${part}")
    done
    local sorted=("${parts[@]}")
    for index in "${!parts[@]}"; do
        local part="${parts[index]}"
        # shellcheck source=./part/*.sh
        source "${part}"
        sorted["$(part::index)"]="${part}"
    done
    echo "${sorted[@]}"
}
#endsection
