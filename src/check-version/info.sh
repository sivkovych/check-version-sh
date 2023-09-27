#section Public API
info::get_usage() {
    echo "Usage:"
    echo "  ${0} --branch-ref string \\"
    echo "                  --commit-ref string \\"
    echo "                  --log-level string \\"
    echo "                  --check-only-for string[]"
    echo ""
    echo "  --branch-ref        string   (required)     git reference to a base branch"
    echo "                                              required only if [--commit-ref] is missing"
    echo "                                              will take priority over [--commit-ref] if both are set"
    echo "                                              (example: feature/check-version-action)"
    echo ""
    echo "  --commit-ref        string   (required)     git reference to a base commit"
    echo "                                              required only if [--branch-ref] is missing"
    echo "                                              will have less priority than [--branch-ref] if both are set"
    echo "                                              (example: 47bed5fa252376fb2ff6738d6e54bde487f05003)"
    echo ""
    echo "  --log-level         string   (optional)     level of a log to print"
    echo "                                              (example: debug)"
    echo ""
    echo "  --check-only-for    string[] (optional)     a list of coma or space separated files to check for"
    echo "                                              (example: pom.xml, package.json)"
    echo ""
}
info::get_description() {
    local supported_files=""
    for version_file in "${PROJECT_DIR}"/version-in/*.sh; do
        # shellcheck source=./version-in/*.sh
        source "${version_file}"
        supported_files="${supported_files}  - $(version::label)\n"
    done
    echo ""
    echo "Parses configuration files and git log to detect and ensure version changes."
    echo "Intended to be used in GitHub Actions."
    echo ""
    echo "Currently supported options:"
    echo -e "${supported_files}"
}
info::get_parameters() {
    local parameters=""
    while [ ${#} -gt 0 ]; do
        local value
                    value=$([[ "${2}" =~ " " ]] && echo "[${2}]" || echo "\"${2}\"")
        parameters="${parameters}\n\t${1} = ${value}"
        shift 2
    done
    echo -e "Parsed parameters:${parameters}"
}
#endsection
