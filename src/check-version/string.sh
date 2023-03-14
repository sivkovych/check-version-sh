#section Public API
string::delimiter() {
    echo "${1}" |
        local::grep -Po "[\W\D]" |
        sort |
        uniq --count |
        head -1 |
        sed -e 's| ||g;s|[0-9]||g'
}
string::element() {
    local delimiter
                     delimiter="$(string::delimiter "${1}")"
    echo "${1}" | cut -d"${delimiter}" -f"${2}"
}
#endsection
