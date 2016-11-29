DEFAULT_COMMAND="list"

source "${DONKEY_LIB}/_common.sh"

function donkey-ec2-list() {
    RAW=false
    while [[ $# > 0 ]]; do
        case "${1}" in
            -r|--raw)                   RAW=true;;
            -f|--fields)                FIELDS="${2}"; shift;;
        esac
        shift
    done

    INSTANCES=$(ruby "${DONKEY_LIB}/_ec2-instances.rb" "${FIELDS}")

    if $RAW; then
        echo "${INSTANCES}"
    else
        echo "${INSTANCES}" | column -t -s ','
    fi
}

function donkey-ec2-help() {
    cat <<EOF
usage: donkey ec2 [command]

Options:
    --profile       Not currently implemented
    --region        Not currently implemented

Available commands:

    list [options]      Lists all ec2 instances
        -f | --fields   Comma seperated list of fields to display
                        Default: Tags.Name,PublicIpAddress,InstanceType,State
                        See https://goo.gl/cW3Vz6 for more options
        -r | --raw      Toggle pretty printing (easier to grep)
EOF
}

function donkey-ec2-info() {
    echo "ec2"
}

function donkey-ec2() {
    SUB_COMMAND=$(find-sub-command "${@}")
    # rewrite aliases
    case "${SUB_COMMAND}" in
        ls)                 SUB_COMMAND="list" ;;
    esac
    call-sub-command "${SUB_COMMAND}" "${@}"
}