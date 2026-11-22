# ==============================================================================
# Script: plan.ps1
# Purpose: Run terraform plan for a target environment (PowerShell)
# Usage: .\scripts\plan.ps1 -Environment [dev|staging|prod]
# ==============================================================================
param (
    [ValidateSet("dev", "staging", "prod")]
    [string]$Environment = "dev"
)

$targetDir = "environments/$Environment"
if (-not (Test-Path $targetDir)) {
    Write-Error "Environment directory '$targetDir' not found."
}

Write-Host "==> Generating Terraform plan for $Environment..." -ForegroundColor Cyan
Push-Location $targetDir
try {
    terraform init
    terraform plan -var-file="terraform.tfvars" -out="$Environment.tfplan"
    Write-Host "==> Plan successfully generated: $targetDir/$Environment.tfplan" -ForegroundColor Green
}
finally {
    Pop-Location
}
