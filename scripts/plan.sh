#!/usr/bin/env bash
# ==============================================================================
# Script: plan.sh
# Purpose: Run terraform plan for a target environment
# Usage: ./scripts/plan.sh [dev|staging|prod]
# ==============================================================================
set -euo pipefail

ENV="${1:-dev}"
DIR="environments/${ENV}"

if [ ! -d "${DIR}" ]; then
    echo "Error: Environment '${ENV}' not found under environments/"
    exit 1
fi

echo "==> Generating Terraform plan for ${ENV} environment..."
cd "${DIR}"
terraform init
terraform plan -var-file="terraform.tfvars" -out="${ENV}.tfplan"
echo "==> Plan completed and saved to ${DIR}/${ENV}.tfplan"
