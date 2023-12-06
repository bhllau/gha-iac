# IAC Github Action

This action can run command based on terraform, awscli, kubectl and helm.

## Example usage

Snippet:

    uses: storyprotocol/gha-iac
    with:
      workdir: tf/targets/staging
      github_token: ${{ secrets.GITHUB_TOKEN }}
      aws_access_key_id: ${{ secrets.AWS_ACCESS_KEY_ID }}
      aws_secret_access_key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
      aws_region: ${{ secrets.AWS_REGION }}
      tf_cli_args_init: ${{ secrets.TF_CLI_ARGS_INIT_STAGING }}
      command: terraform plan

