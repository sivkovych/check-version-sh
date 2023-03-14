#section Public API
array::contains()  {
    local look_for=${1}
    shift
    local array=("${@}")
    for element in "${array[@]}"; do
        if [ "${element}" == "${look_for}" ]; then
            return 0
        fi
    done
    return 1
}
array::not_contains() {
    local look_for=${1}
    shift
    local array=("${@}")
    for element in "${array[@]}"; do
        if [ "${element}" == "${look_for}" ]; then
            return 1
        fi
    done
    return 0
}
array::every()  {
    local look_for="${1}"
    shift
    local array=("${@}")
    for element in "${array[@]}"; do
        if [ "${element}" != "${look_for}" ]; then
            return 1
        fi
    done
    return 0
}
#endsection
