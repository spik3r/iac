# AGENTS.md - Infrastructure as Code Guidelines

## Build/Test Commands
- `make fmt` - Format all Terraform files recursively
- `make validate` - Validate all configurations (bootstrap, buildpipeline, dev, prod)
- `make bootstrap` - Create remote state infrastructure
- `make plan-buildpipeline` / `make apply-buildpipeline` - Plan/apply build pipeline infrastructure
- `make plan-dev` / `make plan-prod` - Plan environment changes
- `make apply-dev` / `make apply-prod` - Apply environment changes
- `make destroy-buildpipeline` - Destroy build pipeline infrastructure (with confirmation)
- `terraform plan -var-file="terraform.tfvars" -var-file="secrets.tfvars"` - Plan with both variable files
- `terraform apply -var-file="terraform.tfvars" -var-file="secrets.tfvars"` - Apply with both variable files
- `terraform validate` - Validate single configuration
- `terraform fmt -recursive` - Format files manually
- Single test: `terraform test -filter=<test_name>` (if configured)

## Variable Files
- `terraform.tfvars` - Main configuration (safe to commit)
- `secrets.tfvars` - Sensitive data (NEVER commit - add to .gitignore)
- `*.tfvars.example` - Templates for both files

## Code Style Guidelines
- **Files**: Use `.tf` for Terraform, organize by `main.tf`, `variables.tf`, `outputs.tf`
- **Naming**: Use snake_case for resources, kebab-case for files, `name_prefix` pattern
- **Variables**: Define in `variables.tf` with descriptions and validation rules
- **Outputs**: Define in `outputs.tf` with meaningful descriptions
- **Modules**: Organize reusable code in `modules/` directory (app-service, networking, etc.)
- **Locals**: Use for computed values and common tags (environment, project, managed_by)
- **Providers**: Pin versions (`~> 3.0` for azurerm), use required_version `>= 1.0`
- **Backend**: Use azurerm backend with separate config files per environment
- **Tags**: Apply consistent tagging strategy using locals.common_tags
- **Formatting**: Always run `terraform fmt` before committing
- **Comments**: Use `#` for single-line, `/* */` for multi-line
- **Secrets**: Never hardcode secrets, use variables or Azure Key Vault
- **Dynamic blocks**: Use for conditional resources (ip_restrictions, etc.)

## Error Handling
- Use `try()` function for optional values
- Implement proper resource dependencies with `depends_on`
- Add lifecycle rules to prevent accidental resource destruction
- Use validation blocks in variables for input validation