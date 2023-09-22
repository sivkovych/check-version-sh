#section Public API
version::label() {
    echo "readme-badge"
}
version::file_name() {
    echo "README.md"
}
version::old() {
    version::_get "${1}" "-"
}
version::new() {
    version::_get "${1}" "+"
}
#endsection
#section Private API
version::_get() {
    echo "${1}" |
        local::grep "${2}" |
        local::grep -m 1 -Po "\b(([\w-]+://?|www[.])[^\s()<>]+badge[^\s()<>]+(?:\([\w\d]+\)|([^[:punct:]\s]|/)))" |
        local::grep -Po "(?<=/badge/version-)((\d+|.)+?)(?=-)"
}
#endsection
