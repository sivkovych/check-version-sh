#section Public API
version::label() {
  echo "package.json"
}
version::file_name() {
    echo "package.json"
}
version::old() {
    version::_get "${1}" "-"
}
version::new() {
    version::_get "${1}" "\+"
}
#endsection
#section Private API
version::_get() {
    echo "${1}" |
        local::grep -m 1 -Po "(?<=^${2}\"version\":\")(([0-9]{1,}|[.-/#])+?)(?=\")"
}
#endsection
