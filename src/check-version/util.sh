#section Public API
null() {
    echo "__NULL__"
}
contains()  {
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
every()  {
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
get_delimiter() {
    echo "${1}" |
        local_grep -Po "[\W\D]" |
        sort |
        uniq --count |
        head -1 |
        sed -e 's| ||g;s|[0-9]||g'
}
get_element() {
    local delimiter
                     delimiter="$(get_delimiter "${1}")"
    echo "${1}" | cut -d"${delimiter}" -f"${2}"
}
get_fail_message() {
    printf "Script failed: %s\n\n" "${1}"
}
get_parts() {
    local current_dir="${1}"
    local parts=()
    for part in "${current_dir}"/part/*.sh; do
        parts+=("${part}")
    done
    echo "${parts[@]}"
}
get_sorted_parts() {
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
        sorted["$(index)"]="${part}"
    done
    echo "${sorted[@]}"
}
#endsection
