function donkey-help() {
    cat <<EOF
usage: donkey <command>

Options:
    --profile       AWS shared credentials profile name
    --region        AWS region

Available commands:
EOF

    (for LIB in $(find ${DONKEY_LIB} -type f -name '*.sh' | xargs -n1 -I@ basename @ .sh); do
        source "${DONKEY_LIB}/${LIB}.sh"
        printf "   "
        INFO_FUNCTION="donkey-${LIB}-info"

        if [ -n "$(type -t ${INFO_FUNCTION})" ] && \
           [ "$(type -t ${INFO_FUNCTION})" = function ]; then
        
          eval ${INFO_FUNCTION}
        fi

    done) | column -c 80
}

function donkey-help-info() {
    echo "help"
}