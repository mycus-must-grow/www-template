#!/usr/bin/env bash
#/scripts/template.sh

# BASHISM: strict mode
set -euo pipefail
IFS=$'\n\t'

scriptDirectory="$(dirname "$0")"
projectRoot="$(readlink -f "$scriptDirectory/..")"
templateFiles="$(cat << EOF
public
LICENSE
EOF
)"
toPath=

usage()
{
    echo "Usage: template.sh \"Destination\""
    echo
    echo "This will deploy this template to the \"Destination\", creating the"
    echo "necessary parent directories in the process."
    echo
    echo "Make sure that the \"Destination\" is either empty or nonexistent."
}

deploy()
{
    toPathClog=$(printf "%s" "$(ls -Ap "$toPath" 2>/dev/null)")

    if [ -z "$toPathClog" ]; then
        mkdir -p "$toPath" && \
        {
            while IFS= read -r line; do
                mkdir -p "$toPath/$(dirname "$line")"
                cp -R "$projectRoot/$line" "$toPath"
            done <<< "$templateFiles"
        }

    else
        printf "FAILED: Destination '%s' is " "$toPath"
        if [ -d "$toPath" ]; then
            printf "clogged by:\n"
            printf "  %s\n" $toPathClog
        else
            printf "a file.\n"
        fi
    fi
}

main()
{
    userNeedsHelp="$( \
        printf "%s\n" "$@" | awk '/^-/ || /^-h$/ || /^--help$/ { print }' )"

    if [ "$userNeedsHelp" ] || [ "$#" -ne 1 ]; then
        usage
        return 1
    fi

    toPath=${1%'/'}

    deploy
}

main "$@"
