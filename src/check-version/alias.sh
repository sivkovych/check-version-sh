shopt -s expand_aliases
if [[ "${OSTYPE}" =~ ^darwin ]]; then
    if ! command -v ggrep >/dev/null; then
        brew install --quiet grep >/dev/null
    fi
    alias local::grep='ggrep'
elif [[ "${OSTYPE}" =~ ^linux ]]; then
    alias local::grep='grep'
fi
