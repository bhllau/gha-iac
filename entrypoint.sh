#!/bin/sh
setup() {
	extract_args "$@"
	if [ ! -d "$WORKDIR" ]; then
		echo "--> Work dir "$WORKDIR" does not exist. Exiting..." >&2
		exit 0
	fi

	create_gitconfig
	cd "$WORKDIR"
	if echo "$COMMAND" | grep -q '^terraform '; then
		terraform init
	fi
}

teardown() {
	rm -f ~/.gitconfig
}

extract_args() {
	local workdir=$1; shift
	local github_token=$1; shift
	local aws_access_key_id=$1; shift
	local aws_secret_access_key=$1; shift
	local aws_region=$1; shift
	local tf_cli_args_init=$1; shift
	local command=$1; shift

	export WORKDIR=$workdir
	export GITHUB_TOKEN=$github_token
	export AWS_ACCESS_KEY_ID=$aws_access_key_id
	export AWS_SECRET_ACCESS_KEY=$aws_secret_access_key
	export AWS_REGION=$aws_region
	export AWS_DEFAULT_REGION=$aws_region
	export TF_CLI_ARGS_init=$tf_cli_args_init
	export COMMAND=$command
}

create_gitconfig() {
	cat >> ~/.gitconfig <<EOF
[url "https://oauth2:${GITHUB_TOKEN}@github.com"]
	insteadOf = https://github.com
EOF
}

parse_and_run_command() {
	echo "--> Executing '$COMMAND'..." >&2
	$COMMAND
}

main() {
	setup "$@"
	parse_and_run_command
	ecode=$?
	teardown
	return $ecode
}

main "$@"

