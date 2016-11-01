

function donkey-elb-help() {
	echo "donkey elb help"
}

function donkey-elb-list() {
	aws elb describe-load-balancers \
		--query 'LoadBalancerDescriptions[*].{Name:LoadBalancerName, Host:DNSName, VPC: VPCId}' \
		--output text |
		column -t

}

function donkey-elb-instances-help() {
	echo "usage: donkey elb instances <elb-name>"
}

function donkey-elb() {
	ARGS_COUNT=${#}
	SUB_COMMAND=${1}
	shift
	case "${SUB_COMMAND}" in
		help | --help | -h) 	    SUB_COMMAND="help" ;;
		version | --version | -v) 	SUB_COMMAND="version" ;;
	esac

	LIB="${DONKEY_LIB}/elb"
	COMMAND_PREFIX="donkey-elb"

	if [[ -f "${LIB}/${SUB_COMMAND}.sh" ]]; then
		BASH_SUB_COMMAND="${LIB}/${SUB_COMMAND}.sh"
	fi

	COMMAND_FUNCTION="${COMMAND_PREFIX}-${SUB_COMMAND}"

	if [[ -n "${BASH_SUB_COMMAND}" ]]; then
		source "${BASH_SUB_COMMAND}"
		{ "${COMMAND_FUNCTION}" "$@"; exit $?; }
	else
		if [[ $(type -t ${COMMAND_FUNCTION}) ]]; then 
			{ "${COMMAND_FUNCTION}" "$@"; exit $?; }
		else
			echo "Unknown command ${SUB_COMMAND}"
			[[ "$ARG_COUNT" -gt 0 ]] && set -- "${SUB_COMMAND}" "$@"
			{ "${COMMAND_PREFIX}-help" "$@"; exit $?; }
		fi
	fi
}
