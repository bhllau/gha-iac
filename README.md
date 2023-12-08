# IAC Github Action

This action can run command based on terraform, awscli, kubectl and helm.

## Example usage

Snippet:

    uses: bhllau/gha-iac
    with:
      workdir: tf/staging
      envblock: |
        GITHUB_TOKEN=xxxxxxx
        AWS_ACCESS_KEY_ID=xxxxxxxxx
        AWS_SECRET_ACCESS_KEY=xxxxxxxxx
        AWS_REGION=xxxxxxx
      command: terraform plan

