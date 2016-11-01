

function donkey-asg-help() {
	echo "donkey asg help"
}

function donkey-asg-list() {
	aws autoscaling describe-auto-scaling-groups \
	| jq -r '.AutoScalingGroups[] | select(.Tags[].Key=="Name") | .Tags[].Value'
}

function donkey-asg-instances-help() {
	echo "usage: donkey asg instances <asg-name>"
}

function donkey-asg-instances() {
	ARGS_COUNT=${#}
	ASG_NAME=${1}
	shift

	while [[ ${#} -gt 1 ]]; do
		KEY="${1}"

		case ${KEY} in
			--profile) 		PROFILE="${1} ${2}"; shift ;;
			--region) 		REGION="${1} ${2}"; shift ;;
			*) ;;
		esac
		shift
	done


	if [[ -z "${ASG_NAME}" ]]; then
		echo "Missing required argument: asg-name"
		{ donkey-asg-instances-help "$@"; exit $?; }
	else
		INSTANCE_QUERY="'AutoScalingInstances[?AutoScalingGroupName==\`${ASG_NAME}\`].InstanceId'"
		set -e
		ASG_INSTANCE_RESULTS=$(echo "aws autoscaling describe-auto-scaling-instances ${PROFILE} ${REGION} --query ${INSTANCE_QUERY} --output text" | sh)
		INSTANCE_IDS=$(echo ${ASG_INSTANCE_RESULTS} | sed -e  's/ / /g')

		if [[ -z "${INSTANCE_IDS}" ]]; then
			echo "No instances found"
			exit
		fi

		aws ec2 describe-instances --instance-ids ${INSTANCE_IDS} \
			--query 'Reservations[*].Instances[?State.Name==`running`].{ID:InstanceId, State:State.Name, Key:KeyName, PublicIP:PublicIpAddress, Host:PublicDnsName}' \
			--output text \
			| column -t
	fi
}

function donkey-asg() {
	ARGS_COUNT=${#}
	SUB_COMMAND=${1}
	shift
	case "${SUB_COMMAND}" in
		help | --help | -h) 	    SUB_COMMAND="help" ;;
		version | --version | -v) 	SUB_COMMAND="version" ;;
	esac

	LIB="${DONKEY_LIB}/asg"
	COMMAND_PREFIX="donkey-asg"

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
