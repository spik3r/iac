# MVP Infrastructure Makefile

.PHONY: help init plan apply destroy clean outputs

# Default target
help:
	@echo "Available commands:"
	@echo "  init     - Initialize Terraform"
	@echo "  plan     - Plan infrastructure changes"
	@echo "  apply    - Apply infrastructure changes"
	@echo "  destroy  - Destroy all infrastructure"
	@echo "  outputs  - Show Terraform outputs"
	@echo "  clean    - Clean Terraform files"
	@echo ""
	@echo "Quick start:"
	@echo "  make init && make plan && make apply"

# Initialize Terraform
init:
	terraform init

# Plan infrastructure changes
plan:
	terraform plan -var-file="terraform.tfvars"

# Apply infrastructure changes
apply:
	terraform apply -var-file="terraform.tfvars"

# Destroy infrastructure
destroy:
	@echo "⚠️  WARNING: This will destroy ALL resources!"
	@echo "Are you sure? Press Ctrl+C to cancel, or Enter to continue..."
	@read
	terraform destroy -var-file="terraform.tfvars"

# Show outputs
outputs:
	terraform output

# Clean Terraform files (keeps state)
clean:
	rm -rf .terraform/
	rm -f .terraform.lock.hcl
	rm -f *.tfplan

# Get Application Insights connection string
connection-string:
	@terraform output -raw application_insights_connection_string

# Get container registry login server
registry:
	@terraform output -raw container_registry_login_server

# Get app service URL
url:
	@terraform output -raw app_service_url