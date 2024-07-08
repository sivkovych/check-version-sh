#!/bin/bash
#section Imports
readonly PROJECT_DIR="$(dirname "${0}")/check-version"
source "${PROJECT_DIR}"/alias.sh
source "${PROJECT_DIR}"/string.sh
source "${PROJECT_DIR}"/number.sh
source "${PROJECT_DIR}"/array.sh
source "${PROJECT_DIR}"/util.sh
source "${PROJECT_DIR}"/git.sh
source "${PROJECT_DIR}"/log.sh
source "${PROJECT_DIR}"/arguments.sh "${*}"
source "${PROJECT_DIR}"/info.sh
source "${PROJECT_DIR}"/check_version.sh
#endsection

log::configure_log "${log_level:-"debug"}"
ref="${1}"
file_path="${2}"
file_label="${3}"
check_version::is_valid_file "${ref}" "${file_path}" "${file_label}"
readonly check_result="${?}"
if [ "${check_result}" == "1" ] || [ "${check_result}" == "66" ]; then
    log::debug "Exit code [1]"
    exit 1
fi
if [ "${check_result}" == "0" ]; then
    log::debug "Exit code [0]"
    exit 0
fi
