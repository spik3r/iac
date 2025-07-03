# AGENTS.md - Infrastructure as Code Guidelines

## Build/Test Commands
- `terraform plan` - Preview infrastructure changes
- `terraform apply` - Apply infrastructure changes
- `terraform validate` - Validate configuration syntax
- `terraform fmt` - Format configuration files
- `terraform test` - Run tests (if configured)
- Single test: `terraform test -filter=<test_name>`

## Code Style Guidelines
- **Files**: Use `.tf` for Terraform, `.yaml`/`.yml` for other configs
- **Naming**: Use snake_case for resources, kebab-case for files
- **Variables**: Define in `variables.tf`, document with descriptions
- **Outputs**: Define in `outputs.tf` with meaningful descriptions
- **Modules**: Organize reusable code in `modules/` directory
- **Formatting**: Always run `terraform fmt` before committing
- **Comments**: Use `#` for single-line, `/* */` for multi-line
- **Secrets**: Never hardcode secrets, use variables or secret managers
- **Tags**: Apply consistent tagging strategy across all resources
- **Validation**: Add variable validation rules where appropriate
- **State**: Use remote state backends for team collaboration
- **Versions**: Pin provider versions in `versions.tf`

## Error Handling
- Use `try()` function for optional values
- Implement proper resource dependencies with `depends_on`
- Add lifecycle rules to prevent accidental resource destruction