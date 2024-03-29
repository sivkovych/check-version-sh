#section Public API
git::branch() {(
    set -e
    git rev-parse --abbrev-ref HEAD
)}
git::fetch() {(
    set -e
    local ref="${1}"
    local branch
                  branch="$(git::branch)"
    local fetch_from="${ref}:refs/remotes/origin/${branch:-${ref}}"
    log::debug "Fetching from [origin ${fetch_from}]"
    git fetch -fq origin "${fetch_from}"
)}
git::diff_files() {(
    set -e
    git diff --name-only "${1}"
)}
git::diff() {(
    set -e
    git diff "${1}" "${2}"
)}
git::get_repository_name() {(
    set -e
    basename "$(git rev-parse --show-toplevel)"
)}
#endsection
