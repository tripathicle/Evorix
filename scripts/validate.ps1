# ==============================================================================
# Script: validate.ps1
# Purpose: Format check, initialize, and validate Terraform configurations (PowerShell)
# ==============================================================================
$ErrorActionPreference = "Stop"

Write-Host "==> Checking Terraform code formatting..." -ForegroundColor Cyan
terraform fmt -check -recursive
if ($LASTEXITCODE -ne 0) {
    Write-Error "Terraform formatting check failed. Run 'terraform fmt -recursive' to fix."
}

$environments = @("environments/dev", "environments/staging", "environments/prod", "bootstrap/terraform-backend")

foreach ($envPath in $environments) {
    Write-Host "==> Validating $envPath..." -ForegroundColor Cyan
    Push-Location $envPath
    try {
        terraform init -backend=false | Out-Null
        $res = terraform validate
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Validation failed for $envPath"
        }
        Write-Host "  [OK] $envPath validated successfully" -ForegroundColor Green
    }
    finally {
        Pop-Location
    }
}

Write-Host "==> All Terraform configurations validated successfully!" -ForegroundColor Green
