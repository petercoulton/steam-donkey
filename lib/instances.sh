function align-columns() {
	HEADERS="${1}"
	ROWS="${2}"
	(printf "${HEADERS}\n"; echo "${ROWS}") | column -t -s ','
}

function list-instances() {
	ASG_NAME=${1}
	INSTANCES=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names ${ASG_NAME} \
					| jq -r '.AutoScalingGroups[]? | .Instances[]?.InstanceId')

	echo "${INSTANCES}"
}

function donkey-instances-help() {
	cat <<EOF
usage: donkey instances <command>

Options:
	--profile
	--region

Available commands:
   ls                               Alias for \`list\`
   list [--profile] [--region]      List runnning EC2 instances

EOF
}

function donkey-instances-info() {
	echo "instances"
}



function donkey-instances-list() {

	if [[ ! "$@" =~ .*--filters.* ]]; then
		PARAMS="--filters Name=instance-state-name,Values=running"
	fi

	while [[ $# > 0 ]]; do
		case "${1}" in
			-r|--raw)	 				RAW=true ;;
			-g|--asg-name)				ASG_NAME="${2}"; shift ;;
			-s|--seperator)				SEPERATOR="${2}"; shift ;;
			*)							PARAMS="${PARAMS} ${1}" ;;
		esac
		shift
	done

	: ${SEPERATOR=""}

	if [[ ! -z "${ASG_NAME}" ]]; then
		INSTANCE_IDS="--instance-ids $(list-instances ${ASG_NAME} | tr '\n' ' ')"
	fi

	INSTANCES=$( aws ec2 describe-instances ${INSTANCE_IDS} ${FILTERS} ${PARAMS} \
		| jq -r '.Reservations[]?.Instances[]? | (.Tags[]?//[]? | select(.Key=="Name")|.Value) as $name | "\(.InstanceId),\($name),\(.PublicDnsName),\(.KeyName)"' \
		| sed -e 's/^,/-,/' -e 's/,,/,-,/g' -e 's/,/,;/g' \
		| sort --field-separator , --key=2 )

	OUTPUT=$( (printf "Instance Id,Name,Public DNS,Key Name\n"; echo "${INSTANCES}") | column -t -s ',' )

	if [[ ! -z "${SEPERATOR}" ]]; then
		OUTPUT="$(echo "${OUTPUT}" | sed -e "s/[[:space:]]*;/${SEPERATOR}/g" )"
	fi

	local BOLD="$(tput bold)"
	local NORMAL="$(tput sgr0)"

	if [[ ${RAW} != true ]]; then
		echo -n ${BOLD}
		echo -n "$( echo "${OUTPUT}" | head -n1 )"
		echo ${NORMAL}
	fi
	echo -n "$( echo "${OUTPUT}" | tail -n +2 )"
}




function donkey-instances() {
	ARG_COUNT="${#}"
	COMMAND="list"
	if [[ ! ${1} =~ ^--.* && ${ARG_COUNT} -gt 0 ]]; then
		COMMAND="${1}"
		shift
	fi

	case "${COMMAND}" in
		ls)	 	    				COMMAND="list" ;;
	esac

	type -t "donkey-instances-${COMMAND}" > /dev/null
	if [[ ${?} -ne 0 ]]; then
		echo "Unknown command: ${COMMAND}"
	else
		{ "donkey-instances-${COMMAND}" "${@}"; exit ${?}; }
	fi
}
