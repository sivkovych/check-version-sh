#section Public API
string::element() {
    string::get_separated "${1}" | cut -d" " -f"${2}"
}
string::get_separated() {
    echo "${1}" | sed "s|\.| |g; s|-| |g; s|_| |g; s|,| |g" | tr -s " "
}
string::get_separated_by_coma() {
    echo "${1}" | sed "s|,| |g" | tr -s " "
}
#endsection
