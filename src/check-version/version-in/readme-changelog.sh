#section Public API
version::label() {
  echo "readme-changelog"
}
version::file_name() {
    echo "README.md"
}
version::old() {
    echo "${1}" |
        local::grep -Pv "^\+" |
        local::grep -Po "(?<=-\s\*\*)((\d+|.)+?)(?=\*\*)" |
        tail -1
}
version::new() {
    echo "${1}" |
        local::grep -P "^\+" |
        local::grep -Po "(?<=-\s\*\*)((\d+|.)+?)(?=\*\*)" |
        tail -1
}
#endsection
