#section Public API
number::format() {
    if [ -z "${1}" ]; then
        echo "0"
    fi
    echo "${1}" |
        sed -r "s/0*([0-9]*)/\1/"
}
#endsection
