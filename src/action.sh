#!/bin/bash
#section Parameter Parsing
if [[ ${#} == 0 ]]; then
    echo "Action failed: No commit/branch references passed"
    exit 1
fi
if [ -z "${1}" ] && [ -z "${2}" ]; then
    echo "Action failed: No commit/branch references passed"
    exit 1
fi
#endsection
#section Execution
check_version_sh="$(dirname "${BASH_SOURCE[0]}")/check-version/check-version.sh"
chmod +x "${check_version_sh}"
./"${check_version_sh}" \
    --branch-ref "${1}" \
    --commit-ref "${2}" \
    --log-level "${3}" \
    --check-only-for "${4}"
exit "${?}"
#endsection
