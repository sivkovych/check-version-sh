readonly old_ifs="${IFS}"
IFS=$'\n'
for argument in ${*//--/$'\n'}; do
    IFS=$' '
    for arg in ${argument}; do
        args+=("$(string::get_separated_by_coma "${arg}")")
    done
    if [ -z "${args[*]}" ]; then
        continue
    fi
    key="${args[0]//-/_}"
    case "${key}" in
    "help")
        info::get_description
        info::get_usage
        exit 0
        ;;
    "branch_ref") declare -xr branch_ref="${args[1]}" ;;
    "commit_ref") declare -xr commit_ref="${args[1]}" ;;
    "log_level") declare -xr log_level="${args[1]}" ;;
    "check_only_for")
        arr=("${args[@]:1}")
        eval declare -axr check_only_for=\("${arr[*]}"\)
        ;;
    esac
    args=()
done
IFS="${old_ifs}"
