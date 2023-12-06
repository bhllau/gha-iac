#!/bin/sh
setup() {
	extract_args "$@"
	if [ ! -d "$WORKDIR" ]; then
		echo "--> Work dir "$WORKDIR" does not exist. Exiting..." >&2
		exit 0
	fi
	cd "$WORKDIR"

	create_gitconfig
	if echo "$COMMAND" | grep -q '^terraform '; then
		restore_tf_modules \
			&& terraform init
	fi
}

teardown() {
	save_tf_modules \
		&& rm -f ~/.gitconfig
}

extract_args() {
	local workdir=$1; shift
	local github_token=$1; shift
	local aws_access_key_id=$1; shift
	local aws_secret_access_key=$1; shift
	local aws_region=$1; shift
	local tf_cli_args_init=$1; shift
	local tf_modules_restore_path=$1; shift
	local command=$1; shift

	export WORKDIR=$workdir
	export GITHUB_TOKEN=$github_token
	export AWS_ACCESS_KEY_ID=$aws_access_key_id
	export AWS_SECRET_ACCESS_KEY=$aws_secret_access_key
	export AWS_REGION=$aws_region
	export AWS_DEFAULT_REGION=$aws_region
	export TF_CLI_ARGS_init=$tf_cli_args_init
	export TF_MODULES_RESTORE_PATH=$tf_modules_restore_path
	export COMMAND=$command
}

create_gitconfig() {
	cat >> ~/.gitconfig <<EOF
[url "https://oauth2:${GITHUB_TOKEN}@github.com"]
	insteadOf = https://github.com
EOF
}

restore_tf_modules() {
	local filename=.terraform.tar.gz
	local target="$TF_MODULES_RESTORE_PATH"/$filename
	if [ ! -d .terraform ] \
		&& [ -n "$TF_MODULES_RESTORE_PATH" ] \
		&& aws s3 ls "$target" --quiet; then
		echo '--> Restoring terraform modules...' >&2
		aws s3 cp "$target" ./"$filename" --quiet \
			&& tar -xzf "$filename" \
			&& rm -f "$filename"
	fi
}

save_tf_modules() {
	local filename=.terraform.tar.gz
	local target="$TF_MODULES_RESTORE_PATH"/$filename
	if [ -d .terraform ] && [ -n "$TF_MODULES_RESTORE_PATH" ]; then
		echo '--> Saving terraform modules...' >&2
		tar -czf "$filename" .terraform .terraform.lock.hcl \
			&& aws s3 cp "$filename" "$target" --quiet \
			&& rm -f "$filename"
	fi
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

