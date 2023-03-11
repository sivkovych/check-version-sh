#section Public API
get_usage() {
    echo "usage:"
    echo "    check-version --branch-ref string \\"
    echo "                  --commit-ref string \\"
    echo "                  --log-level string \\"
    echo "                  --check-only-for string"
    echo ""
    echo "  --branch-ref string (required)         git reference to a base branch"
    echo "                                         required only if [--commit-ref] is missing"
    echo "                                         will take priority over [--commit-ref] if both are set"
    echo "                                         (example: feature/check-version-action)"
    echo ""
    echo "  --commit-ref string (required)         git reference to a base commit"
    echo "                                         required only if [--branch-ref] is missing"
    echo "                                         will have less priority than [--branch-ref] if both are set"
    echo "                                         (example: 47bed5fa252376fb2ff6738d6e54bde487f05003)"
    echo ""
    echo "  --log-level string (optional)          level of a log to print"
    echo "                                         (example: debug)"
    echo ""
    echo "  --check-only-for string (optional)     a single configuration file to check for"
    echo "                                         (example: pom.xml)"
    echo ""
}
get_description() {
    local current_dir
    current_dir=$(dirname "${BASH_SOURCE[0]}")
    local supported_files=""
    for version_file in "${current_dir}"/version-file/*.sh; do
        # shellcheck source=./version-file/*.sh
        source "${version_file}"
        supported_files="${supported_files}  - $(name)\n"
    done
    echo ""
    echo "Parses configuration files and git log to detect and ensure version changes."
    echo "Intended to be used in GitHub Actions."
    echo ""
    echo "Currently supported configuration files:"
    echo -e "${supported_files}"
}
#endsection
