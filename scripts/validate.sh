#!/usr/bin/env bash
# ==============================================================================
# Script: validate.sh
# Purpose: Format check, initialize, and validate Terraform configurations
# ==============================================================================
set -euo pipefail

echo "==> Running terraform fmt check..."
terraform fmt -check -recursive

ENVIRONMENTS=("environments/dev" "environments/staging" "environments/prod" "bootstrap/terraform-backend")

for env in "${ENVIRONMENTS[@]}"; do
    echo "==> Validating ${env}..."
    (
        cd "${env}"
        terraform init -backend=false
        terraform validate
    )
done

echo "==> All Terraform configurations validated successfully!"
