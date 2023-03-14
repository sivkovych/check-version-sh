#section Public API
git::branch() {(
    set -e
    git branch --show-current
)}
git::fetch() {(
    set -e
    local branch
                  branch="$(git::branch)"
    log::debug "Fetching from [origin ${1}:refs/remotes/origin/${branch}]"
    git fetch -fq origin "${1}:refs/remotes/origin/${branch}"
)}
git::diff_files() {(
    set -e
    git diff --name-only "${1}"
)}
git::diff() {(
    set -e
    git diff "${1}" "${2}"
)}
#endsection
