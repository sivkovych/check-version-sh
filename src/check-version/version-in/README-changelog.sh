#section Public API
version::label() {
  echo "README-changelog"
}
version::file_name() {
    echo "README.md"
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
        local::grep -m 1 -Po ""
}
#endsection
