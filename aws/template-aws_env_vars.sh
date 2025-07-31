#!/bin/bash
# aws_env_vars.sh - Source this to set AWS environment variables for Terraform/scripts

# --- Edit these values or use environment/secret managers for production ---

export AWS_REGION="eu-west-2"
export AWS_ACCESS_KEY_ID="YOUR_AWS_ACCESS_KEY_ID"
export AWS_SECRET_ACCESS_KEY="YOUR_AWS_SECRET_ACCESS_KEY"
# Optional: If you use temporary credentials (like from AWS SSO, MFA, or STS):
# export AWS_SESSION_TOKEN="YOUR_SESSION_TOKEN"

# Optional: Set a default profile (if you use ~/.aws/credentials with named profiles)
# export AWS_PROFILE="your-profile-name"

# --- Other recommended variables for scripting/CI ---

export TF_VAR_aws_region="$AWS_REGION"

# --- Prevent accidental leaks in logs ---
set +x

# --- Confirm loaded ---
echo "AWS environment variables set for region $AWS_REGION"