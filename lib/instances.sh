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

function donkey-instances-list() {
	ARG_COUNT="${#}"

	while [[ $# > 1 ]]; do
		case "${1}" in
			--profile) 	AWS_PROFILE="${1} ${2}"; shift ;;
			--region) 	AWS_REGION="${1} ${2}"; shift ;;
		esac
		shift
	done

	(printf 'Instance Id,Name,Public DNS,Key Name\n'; \
	(aws ec2 describe-instances \
	 ${AWS_PROFILE} \
	 ${AWS_REGION} \
	 --filters 'Name=instance-state-name,Values=running' \
	 | jq -r '.Reservations[]?.Instances[]? | (.Tags[]?//[]? | select(.Key=="Name")|.Value) as $name | "\(.InstanceId),\($name),\(.PublicDnsName),\(.KeyName)"' \
	 | sed -e 's/^,/-,/' -e 's/,,/,-,/g' \
	 | sort --field-separator , --key=2 )) \
	| column -t -s ','
}

function donkey-instances-help() {
	cat <<EOF
usage: donkey instances <command>

Available commands:
   ls                               Alias for \`list\`
   list [--profile] [--region]      List runnning EC2 instances

EOF
}

function donkey-instances-info() {
	echo "instances"
}
