# ==============================================================================
# Script: deploy.ps1
# Purpose: Apply Terraform plan for an approved deployment (PowerShell)
# Usage: .\scripts\deploy.ps1 -Environment [dev|staging|prod]
# ==============================================================================
param (
    [ValidateSet("dev", "staging", "prod")]
    [string]$Environment = "dev",
    [switch]$AutoApprove
)

$targetDir = "environments/$Environment"
$planFile = "$Environment.tfplan"

Push-Location $targetDir
try {
    if (-not (Test-Path $planFile)) {
        Write-Host "==> Generating plan for $Environment..." -ForegroundColor Cyan
        terraform init
        terraform plan -var-file="terraform.tfvars" -out=$planFile
    }

    if (-not $AutoApprove) {
        $confirm = Read-Host "Proceed with deployment to $Environment? (type 'yes' to proceed)"
        if ($confirm -ne "yes") {
            Write-Host "Deployment aborted by operator." -ForegroundColor Yellow
            return
        }
    }

    terraform apply $planFile
    Write-Host "==> Deployment for $Environment finished successfully!" -ForegroundColor Green
}
finally {
    Pop-Location
}
