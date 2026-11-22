#!/usr/bin/env bash
# ==============================================================================
# Script: deploy.sh
# Purpose: Apply Terraform plan for an approved deployment
# Usage: ./scripts/deploy.sh [dev|staging|prod]
# ==============================================================================
set -euo pipefail

ENV="${1:-dev}"
DIR="environments/${ENV}"
PLAN_FILE="${ENV}.tfplan"

if [ ! -d "${DIR}" ]; then
    echo "Error: Environment '${ENV}' not found."
    exit 1
fi

cd "${DIR}"

if [ ! -f "${PLAN_FILE}" ]; then
    echo "Plan file '${PLAN_FILE}' not found. Generating fresh plan..."
    terraform init
    terraform plan -var-file="terraform.tfvars" -out="${PLAN_FILE}"
fi

echo "================================================================="
echo "WARNING: Applying infrastructure changes for: ${ENV}"
echo "================================================================="
read -p "Do you want to proceed with terraform apply? (yes/no): " CONFIRM
if [ "${CONFIRM}" != "yes" ]; then
    echo "Deployment cancelled by user."
    exit 0
fi

terraform apply "${PLAN_FILE}"
echo "==> Deployment of ${ENV} completed successfully!"
