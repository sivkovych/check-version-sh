#section Public API
get_name() {
    echo "pom.xml"
}
get_old_version() {
    _get_version "${1}" "-"
}
get_new_version() {
    _get_version "${1}" "\+"
}
#endsection
#section Private API
_get_version() {
    echo "${1}" |
        local_grep -Po "(?<=^${2}<version>)((\d+|.)+?)(?=<\/version>)"
}
#endsection
