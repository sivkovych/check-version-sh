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
        local::grep -Po "(?<=-\*\*)[\w|](([0-9]{1,}|[.-/#])+?)(?=\*\*)" |
        sed "s|[^0-9.-/#]||g" |
        tail -1
}
version::new() {
    echo "${1}" |
        local::grep "+" |
        local::grep -Po "(?<=-\*\*)[\w|](([0-9]{1,}|[.-/#])+?)(?=\*\*)" |
        sed "s|[^0-9.-/#]||g" |
        tail -1
}
#endsection
