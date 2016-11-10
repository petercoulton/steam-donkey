function align-columns() {
	HEADERS="${1}"
	ROWS="${2}"
	(printf "${HEADERS}\n"; echo "${ROWS}") | column -t -s ','
}

function list-asgs() {
	AUTO_SCALING_GROUPS=$(aws autoscaling describe-auto-scaling-groups ${1} \
 		| jq -r '.AutoScalingGroups[]? | "\(.AutoScalingGroupName),\(.LaunchConfigurationName),\(.Instances | length),\(.DesiredCapacity),\(.MinSize),\(.MaxSize)"' \
 		| sed -e 's/^,/-,/' -e 's/,,/,-,/g' \
 		| sort --field-separator , --key=3 --reverse )

	echo "$(align-columns "Name,Launch Configuration,Instances,Desired,Min,Max" "${AUTO_SCALING_GROUPS}")"
}

function list-asg-names() {
	AUTO_SCALING_GROUPS=$(aws autoscaling describe-auto-scaling-groups ${1} \
 		| jq -r '.AutoScalingGroups[]? | "\(.AutoScalingGroupName)"' \
 		| sed -e 's/^,/-,/' -e 's/,,/,-,/g' \
 		| sort --field-separator , --key=1 )

	echo "Name"
	echo "${AUTO_SCALING_GROUPS}"
}

function donkey-asg-help() {
	cat <<EOF
usage: donkey asg <command>

Options:
	--profile
	--region

Available commands:
   ls           List asgs
   list         List asgs
EOF
}

function donkey-asg-info() {
	echo "asg"
}


function donkey-asg-list() {
	while [[ $# > 0 ]]; do
		case "${1}" in
			-r|--raw)	 		RAW=true ;;
			-1|--name-only)	 	NAME_ONLY=true ;;
			*)					PARAMS="${PARAMS} ${1}" ;;
		esac
		shift
	done

	if [[ ${NAME_ONLY} == true ]]; then
		OUTPUT="$(list-asg-names "${PARAMS}")"
	else
		OUTPUT="$(list-asgs "${PARAMS}")"
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



function donkey-asg() {
	ARG_COUNT="${#}"
	COMMAND="list"
	if [[ ! ${1} =~ ^--.* && ${ARG_COUNT} -gt 0 ]]; then
		COMMAND="${1}"
		shift
	fi

	case "${COMMAND}" in
		ls)	 	    		COMMAND="list" ;;
	esac

	type -t "donkey-asg-${COMMAND}" > /dev/null
	if [[ ${?} -ne 0 ]]; then
		echo "Unknown command: ${COMMAND}"
	else
		{ "donkey-asg-${COMMAND}" "${@}"; exit ${?}; }
	fi
}