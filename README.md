# Enterprise Azure Landing Zone

Production-grade Azure Hub-and-Spoke high availability infrastructure implemented with Terraform (AzureRM 4.x).

## Structure

- `bootstrap/terraform-backend`: Standalone state storage provisioning.
- `modules/`: 22 reusable infrastructure modules.
- `environments/`: Environment-specific configurations for `dev`, `staging`, and `prod`.
- `global/`: Shared naming rules, tagging standards, and local constants.
- `scripts/`: Validation and deployment automation scripts.
- `.github/workflows/`: CI/CD automation pipelines for validation, planning, and deployment.
- `docs/`: Technical specifications for architecture, networking, security, and disaster recovery.

## Quick Start

1. Format and validate configuration:
   ```bash
   ./scripts/validate.sh
   ```
2. Provision bootstrap state storage:
   ```bash
   cd bootstrap/terraform-backend && terraform init && terraform apply
   ```
3. Plan and deploy the target environment:
   ```bash
   cd environments/prod && terraform init && terraform plan
   ```
