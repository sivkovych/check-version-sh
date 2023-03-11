#section Declarations
_log_level=2
#endsection
#section Public API
configure_log() {
    if [[ -n ${1} ]]; then
        _log_level=$(_to_number "${1}")
    fi
}
trace() {
    _log 0 "${1}"
    return 0
}
debug() {
    _log 1 "${1}"
    return 0
}
info() {
    _log 2 "${1}"
    return 0
}
warn() {
    _log 3 "${1}"
    return 0
}
error() {
    _log 4 "${1}"
    return 1
}
fail() {
    error "${1}"
    debug "Exit code [1]"
    exit 1
}
#endsection
#section Private API
_log() {
    if [[ ${_log_level} -le ${1} ]] && [ -n "${2}" ]; then
        echo -e "$(date +%F_%H-%M-%S) [$(_to_string "${1}")] -- ${2}"
    fi
}
_to_number() {
    case "$(echo "${1}" | tr "[:lower:]" "[:upper:]")" in
        "TRACE") echo 0 ;;
        "DEBUG") echo 1 ;;
        "INFO") echo 2 ;;
        "WARN") echo 3 ;;
        "ERROR") echo 4 ;;
        *) echo 2 ;;
    esac
}
_to_string() {
    case "${1}" in
        0) echo "TRACE" ;;
        1) echo "DEBUG" ;;
        2) echo "INFO" ;;
        3) echo "WARN" ;;
        4) echo "ERROR" ;;
        *) echo "INFO" ;;
    esac
}
#endsection
