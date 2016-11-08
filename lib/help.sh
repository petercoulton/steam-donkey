function donkey-help() {
	cat <<EOF
usage: donkey <command>

Available commands:
EOF

	(for LIB in $(find ./lib -type f -name '*.sh' | xargs -n1 -I@ basename @ .sh); do
		source "${DONKEY_LIB}/${LIB}.sh"
		printf "   "
		eval "donkey-${LIB}-info"
	done) | column -c 80
}

function donkey-help-info() {
	echo "help"
}