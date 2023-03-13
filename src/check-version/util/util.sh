#section Public API
util::fail_message() {
    printf "Script failed: %s\n\n" "${1}"
}
util::sorted_parts() {
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
