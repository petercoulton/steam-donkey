function call-sub-command() {
	COMMAND=${1}
	type -t "donkey-${DONKEY_COMMAND}-${COMMAND}" > /dev/null
	if [[ ${?} -ne 0 ]]; then
		echo "Unknown command: ${COMMAND}"
	else
		{ "donkey-${DONKEY_COMMAND}-${COMMAND}" "${@}"; exit ${?}; }
	fi
}

function find-sub-command() {
	ARG_COUNT="${#}"
	SUB_COMMAND=${DEFAULT_COMMAND}
	if [[ ! ${1} =~ ^--.* && ${ARG_COUNT} -gt 0 ]]; then
		SUB_COMMAND="${1}"
	fi
	echo "${SUB_COMMAND}"
}

