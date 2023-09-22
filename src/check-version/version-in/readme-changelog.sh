#section Public API
version::label() {
  echo "readme-changelog"
}
version::file_name() {
    echo "README.md"
}
version::old() {
    echo "${1}" |
        local::grep -v "+" |
        local::grep -Po "(?<=-\*\*)(([0-9]{1,}|[.-/#])+?)(?=\*\*)" |
        tail -1
}
version::new() {
    echo "${1}" |
        local::grep "+" |
        local::grep -Po "(?<=-\*\*)(([0-9]{1,}|[.-/#])+?)(?=\*\*)" |
        tail -1
}
#endsection
